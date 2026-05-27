# Create new security groups
resource "aws_security_group" "sg" {
  for_each = {
    for sg_key, sg_config in var.security_groups : sg_key => sg_config
    if tostring(lookup(sg_config, "create_new_sg", "true")) == "true"
  }

  name_prefix = "${each.value.name}-"
  description = each.value.name
  vpc_id      = each.value.vpc_id

  tags = merge(var.tags, { Name = each.value.name })

  lifecycle {
    create_before_destroy = true
  }
}

# Data source for existing security groups
data "aws_security_group" "existing" {
  for_each = {
    for sg_key, sg_config in var.security_groups : sg_key => sg_config
    if tostring(lookup(sg_config, "create_new_sg", "true")) == "false" && tostring(lookup(sg_config, "existing_sg_id", "")) != ""
  }
  id = tostring(each.value.existing_sg_id)
}

# Security group rules for both new and existing SGs
resource "aws_security_group_rule" "this" {
  for_each = {
    for rule_key, rule_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for rule_name, rule_config in sg_value.rules : {
          key                      = "${sg_key}-${rule_name}"
          sg_key                   = sg_key
          create_new_sg            = tostring(lookup(sg_value, "create_new_sg", "true"))
          type                     = rule_config.type
          from_port                = rule_config.from_port
          to_port                  = rule_config.to_port
          protocol                 = rule_config.protocol
          cidr_blocks              = lookup(rule_config, "cidr_blocks", null)
          source_security_group_id = lookup(rule_config, "source_sg_id", null)
          prefix_list_ids          = lookup(rule_config, "prefix_list_ids", null)
          description              = lookup(rule_config, "description", null)
        }
      ]
    ]) : rule_value.key => rule_value
  }

  type      = each.value.type
  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol

  security_group_id        = tostring(lookup(var.security_groups[each.value.sg_key], "create_new_sg", "true")) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids          = each.value.prefix_list_ids
  description              = each.value.description
}

# ENI attachments for manual ENI IDs
resource "aws_network_interface_sg_attachment" "manual" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for eni_name, eni_id in lookup(sg_value, "eni_ids", {}) : {
          key                  = "${sg_key}-${eni_name}"
          sg_key               = sg_key
          create_new_sg        = tostring(lookup(sg_value, "create_new_sg", "true"))
          network_interface_id = eni_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.network_interface_id
}

# RDS Cluster attachments
resource "null_resource" "rds_sg_attachment" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_id in lookup(lookup(sg_value, "service_attachments", {}), "rds_clusters", []) : {
          key           = "${sg_key}-rds-cluster-${cluster_id}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          cluster_id    = cluster_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  triggers = {
    sg_id       = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
    cluster_id  = each.value.cluster_id
    cluster_arn = data.aws_rds_cluster.specific_clusters[each.value.cluster_id].arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      EXISTING_SGS=$(aws rds describe-db-clusters \
        --db-cluster-identifier ${self.triggers.cluster_id} \
        --query 'DBClusters[0].VpcSecurityGroups[*].VpcSecurityGroupId' \
        --output text | tr '\t' ' ')
      ALL_SGS=$(echo "$EXISTING_SGS ${self.triggers.sg_id}" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
      aws rds modify-db-cluster \
        --db-cluster-identifier ${self.triggers.cluster_id} \
        --vpc-security-group-ids $ALL_SGS \
        --apply-immediately
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      EXISTING_SGS=$(aws rds describe-db-clusters \
        --db-cluster-identifier ${self.triggers.cluster_id} \
        --query 'DBClusters[0].VpcSecurityGroups[*].VpcSecurityGroupId' \
        --output text | tr '\t' ' ')
      REMAINING_SGS=$(echo "$EXISTING_SGS" | tr ' ' '\n' | grep -v "^${self.triggers.sg_id}$" | tr '\n' ' ' | xargs)
      if [ -z "$REMAINING_SGS" ]; then
        echo "Cannot remove last SG from RDS cluster, skipping"
      else
        aws rds modify-db-cluster \
          --db-cluster-identifier ${self.triggers.cluster_id} \
          --vpc-security-group-ids $REMAINING_SGS \
          --apply-immediately
      fi
    EOT
  }
}

# RDS Instance attachments
resource "aws_network_interface_sg_attachment" "rds_instances" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for instance_id in lookup(lookup(sg_value, "service_attachments", {}), "rds_instances", []) : {
          key           = "${sg_key}-rds-instance-${instance_id}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          instance_id   = instance_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = data.aws_db_instance.specific_instances[each.value.instance_id].network_interface_ids[0]
}

# EFS Mount Target attachments
resource "null_resource" "efs_sg_attachment" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for fs_id in lookup(lookup(sg_value, "service_attachments", {}), "efs_filesystems", []) : {
          key           = "${sg_key}-efs-${fs_id}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          fs_id         = fs_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  triggers = {
    sg_id = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
    fs_id = each.value.fs_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      MOUNT_TARGET_IDS=$(aws efs describe-mount-targets \
        --file-system-id ${self.triggers.fs_id} \
        --query 'MountTargets[*].MountTargetId' \
        --output text)
      for MT_ID in $MOUNT_TARGET_IDS; do
        EXISTING_SGS=$(aws efs describe-mount-target-security-groups \
          --mount-target-id $MT_ID --query 'SecurityGroups' \
          --output text | tr '\t' ' ')
        ALL_SGS=$(echo "$EXISTING_SGS ${self.triggers.sg_id}" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
        aws efs modify-mount-target-security-groups \
          --mount-target-id $MT_ID --security-groups $ALL_SGS
      done
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      MOUNT_TARGET_IDS=$(aws efs describe-mount-targets \
        --file-system-id ${self.triggers.fs_id} \
        --query 'MountTargets[*].MountTargetId' \
        --output text)
      for MT_ID in $MOUNT_TARGET_IDS; do
        EXISTING_SGS=$(aws efs describe-mount-target-security-groups \
          --mount-target-id $MT_ID --query 'SecurityGroups' \
          --output text | tr '\t' ' ')
        REMAINING_SGS=$(echo "$EXISTING_SGS" | tr ' ' '\n' | grep -v "^${self.triggers.sg_id}$" | tr '\n' ' ' | xargs)
        if [ -z "$REMAINING_SGS" ]; then
          echo "Cannot remove last SG from EFS mount target, skipping"
        else
          aws efs modify-mount-target-security-groups \
            --mount-target-id $MT_ID --security-groups $REMAINING_SGS
        fi
      done
    EOT
  }
}

# Redis/ElastiCache attachments
resource "null_resource" "redis_sg_attachment" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_id in lookup(lookup(sg_value, "service_attachments", {}), "redis_clusters", []) : {
          key           = "${sg_key}-redis-${cluster_id}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          cluster_id    = cluster_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  triggers = {
    sg_id      = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
    cluster_id = each.value.cluster_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      EXISTING_SGS=$(aws elasticache describe-replication-groups \
        --replication-group-id ${self.triggers.cluster_id} \
        --query 'ReplicationGroups[0].SecurityGroups[*].SecurityGroupId' \
        --output text | tr '\t' ' ' | tr -d '\n' | sed 's/None//g' | xargs)
      if [ -z "$EXISTING_SGS" ]; then
        ALL_SGS="${self.triggers.sg_id}"
      else
        ALL_SGS=$(echo "$EXISTING_SGS ${self.triggers.sg_id}" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ' | xargs)
      fi
      aws elasticache modify-replication-group \
        --replication-group-id ${self.triggers.cluster_id} \
        --security-group-ids $ALL_SGS \
        --apply-immediately
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      EXISTING_SGS=$(aws elasticache describe-replication-groups \
        --replication-group-id ${self.triggers.cluster_id} \
        --query 'ReplicationGroups[0].SecurityGroups[*].SecurityGroupId' \
        --output text | tr '\t' ' ' | tr -d '\n' | sed 's/None//g' | xargs)
      REMAINING_SGS=$(echo "$EXISTING_SGS" | tr ' ' '\n' | grep -v "^${self.triggers.sg_id}$" | grep -v '^$' | tr '\n' ' ' | xargs)
      if [ -z "$REMAINING_SGS" ]; then
        echo "Cannot remove last SG from Redis, skipping"
      else
        aws elasticache modify-replication-group \
          --replication-group-id ${self.triggers.cluster_id} \
          --security-group-ids $REMAINING_SGS \
          --apply-immediately
        aws elasticache wait replication-group-available \
          --replication-group-id ${self.triggers.cluster_id}
        echo "Waiting for ENIs to be released..."
        for i in $(seq 1 60); do
          COUNT=$(aws ec2 describe-network-interfaces \
            --filters "Name=group-id,Values=${self.triggers.sg_id}" \
            --query 'length(NetworkInterfaces)' --output text)
          if [ "$COUNT" = "0" ]; then break; fi
          sleep 10
        done
      fi
    EOT
  }
}

# EKS Cluster attachments
resource "null_resource" "eks_sg_attachment" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_name in lookup(lookup(sg_value, "service_attachments", {}), "eks_clusters", []) : {
          key           = "${sg_key}-eks-${cluster_name}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          cluster_name  = cluster_name
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  triggers = {
    sg_id        = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
    cluster_name = each.value.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      EXISTING_SGS=$(aws eks describe-cluster \
        --name ${self.triggers.cluster_name} \
        --query 'cluster.resourcesVpcConfig.securityGroupIds' \
        --output text | tr '\t' ' ')
      ALL_SGS=$(echo "$EXISTING_SGS ${self.triggers.sg_id}" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ',' | sed 's/,$//')
      aws eks update-cluster-config \
        --name ${self.triggers.cluster_name} \
        --resources-vpc-config "securityGroupIds=$ALL_SGS"
      aws eks wait cluster-active --name ${self.triggers.cluster_name}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      EXISTING_SGS=$(aws eks describe-cluster \
        --name ${self.triggers.cluster_name} \
        --query 'cluster.resourcesVpcConfig.securityGroupIds' \
        --output text | tr '\t' ' ')
      REMAINING_SGS=$(echo "$EXISTING_SGS" | tr ' ' '\n' | grep -v "^${self.triggers.sg_id}$" | grep -v '^$' | tr '\n' ',' | sed 's/,$//')
      if [ -z "$REMAINING_SGS" ]; then
        echo "No additional SGs on EKS cluster, skipping"
      else
        aws eks update-cluster-config \
          --name ${self.triggers.cluster_name} \
          --resources-vpc-config "securityGroupIds=$REMAINING_SGS"
        aws eks wait cluster-active --name ${self.triggers.cluster_name}
      fi
      echo "Waiting for ENIs to be released..."
      for i in $(seq 1 60); do
        COUNT=$(aws ec2 describe-network-interfaces \
          --filters "Name=group-id,Values=${self.triggers.sg_id}" \
          --query 'length(NetworkInterfaces)' --output text)
        if [ "$COUNT" = "0" ]; then break; fi
        sleep 10
      done
    EOT
  }
}

# EC2 Instance attachments
resource "aws_network_interface_sg_attachment" "ec2" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for instance_name in lookup(lookup(sg_value, "service_attachments", {}), "ec2_instances", []) : [
          for idx, eni in [data.aws_instance.specific_ec2[instance_name].network_interface_id] : {
            key           = "${sg_key}-ec2-${instance_name}-${idx}"
            sg_key        = sg_key
            create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
            eni_id        = eni
          }
        ]
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}

# VPC Endpoint attachments
resource "null_resource" "vpc_endpoint_sg_attachment" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for endpoint_id in lookup(lookup(sg_value, "service_attachments", {}), "vpc_endpoints", []) : {
          key           = "${sg_key}-vpce-${endpoint_id}"
          sg_key        = sg_key
          create_new_sg = tostring(lookup(sg_value, "create_new_sg", "true"))
          endpoint_id   = endpoint_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  triggers = {
    sg_id       = tostring(each.value.create_new_sg) == "true" ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
    endpoint_id = each.value.endpoint_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 modify-vpc-endpoint \
        --vpc-endpoint-id ${self.triggers.endpoint_id} \
        --add-security-group-ids ${self.triggers.sg_id}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      aws ec2 modify-vpc-endpoint \
        --vpc-endpoint-id ${self.triggers.endpoint_id} \
        --remove-security-group-ids ${self.triggers.sg_id}
    EOT
  }
}
