# Create new security groups
resource "aws_security_group" "sg" {
  for_each = {
    for sg_key, sg_config in var.security_groups : sg_key => sg_config
    if lookup(sg_config, "create_new_sg", true) == true
  }

  name        = each.value.name
  description = each.value.name
  vpc_id      = each.value.vpc_id

  tags = var.tags
}

# Data source for existing security groups
data "aws_security_group" "existing" {
  for_each = {
    for sg_key, sg_config in var.security_groups : sg_key => sg_config
    if lookup(sg_config, "create_new_sg", true) == false
  }

  id = each.value.existing_sg_id
}

locals {
  # Flatten all rules with resolved SG IDs
  all_rules = flatten([
    for sg_key, sg_value in var.security_groups : [
      for rule_name, rule_config in sg_value.rules : {
        key               = "${sg_key}-${rule_name}"
        sg_key            = sg_key
        create_new_sg     = lookup(sg_value, "create_new_sg", true)
        type              = rule_config.type
        from_port         = rule_config.from_port
        to_port           = rule_config.to_port
        protocol          = rule_config.protocol
        cidr_blocks       = lookup(rule_config, "cidr_blocks", null)
        source_sg_id      = (
          lookup(rule_config, "source_sg_key", null) != null
          ? (
              lookup(var.security_groups[rule_config.source_sg_key], "create_new_sg", true)
              ? aws_security_group.sg[rule_config.source_sg_key].id
              : data.aws_security_group.existing[rule_config.source_sg_key].id
            )
          : lookup(rule_config, "source_sg_id", null)
        )
        prefix_list_ids   = lookup(rule_config, "prefix_list_ids", null)
        description       = lookup(rule_config, "description", "")
      }
    ]
  ])

  ingress_rules = { for r in local.all_rules : r.key => r if r.type == "ingress" }
  egress_rules  = { for r in local.all_rules : r.key => r if r.type == "egress" }
}

# ── Ingress Rules ─────────────────────────────────────────────
resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id

  cidr_blocks              = each.value.source_sg_id == null && (each.value.prefix_list_ids == null || length(try(each.value.prefix_list_ids, [])) == 0) ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id
  prefix_list_ids          = each.value.source_sg_id == null ? each.value.prefix_list_ids : null

  description = each.value.description

  timeouts {
    create = "5m"
  }

  depends_on = [aws_security_group.sg]
}

# ── Egress Rules ──────────────────────────────────────────────
resource "aws_security_group_rule" "egress" {
  for_each = local.egress_rules

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id

  cidr_blocks              = each.value.source_sg_id == null && (each.value.prefix_list_ids == null || length(try(each.value.prefix_list_ids, [])) == 0) ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id
  prefix_list_ids          = each.value.source_sg_id == null ? each.value.prefix_list_ids : null

  description = each.value.description

  timeouts {
    create = "5m"
  }

  depends_on = [aws_security_group.sg]
}

# ── ENI attachments — manual ──────────────────────────────────
resource "aws_network_interface_sg_attachment" "manual" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for eni_name, eni_id in lookup(sg_value, "eni_ids", {}) : {
          key                  = "${sg_key}-${eni_name}"
          sg_key               = sg_key
          create_new_sg        = lookup(sg_value, "create_new_sg", true)
          network_interface_id = eni_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.network_interface_id
}

# ── RDS Cluster attachments ───────────────────────────────────
resource "aws_network_interface_sg_attachment" "rds_clusters" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_id in lookup(lookup(sg_value, "service_attachments", {}), "rds_clusters", []) : {
          key           = "${sg_key}-rds-cluster-${cluster_id}"
          sg_key        = sg_key
          create_new_sg = lookup(sg_value, "create_new_sg", true)
          cluster_id    = cluster_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = data.aws_rds_cluster.specific_clusters[each.value.cluster_id].network_interface_ids[0]
}

# ── RDS Instance attachments ──────────────────────────────────
resource "aws_network_interface_sg_attachment" "rds_instances" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for instance_id in lookup(lookup(sg_value, "service_attachments", {}), "rds_instances", []) : {
          key           = "${sg_key}-rds-instance-${instance_id}"
          sg_key        = sg_key
          create_new_sg = lookup(sg_value, "create_new_sg", true)
          instance_id   = instance_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = data.aws_db_instance.specific_instances[each.value.instance_id].network_interface_id
}

# ── EFS attachments ───────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "efs" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for fs_id in lookup(lookup(sg_value, "service_attachments", {}), "efs_filesystems", []) : {
          key           = "${sg_key}-efs-${fs_id}"
          sg_key        = sg_key
          create_new_sg = lookup(sg_value, "create_new_sg", true)
          eni_id        = data.aws_efs_mount_target.specific_efs[fs_id].network_interface_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}

# ── Redis attachments ─────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "redis" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_id in lookup(lookup(sg_value, "service_attachments", {}), "redis_clusters", []) : [
          for idx, node in data.aws_elasticache_replication_group.specific_redis[cluster_id].cache_nodes : {
            key           = "${sg_key}-redis-${cluster_id}-${idx}"
            sg_key        = sg_key
            create_new_sg = lookup(sg_value, "create_new_sg", true)
            eni_id        = node.network_interface_id
          }
        ]
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}

# ── EKS attachments ───────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "eks" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for cluster_name in lookup(lookup(sg_value, "service_attachments", {}), "eks_clusters", []) : [
          for idx, eni in data.aws_eks_cluster.specific_eks[cluster_name].vpc_config[0].network_interface_ids : {
            key           = "${sg_key}-eks-${cluster_name}-${idx}"
            sg_key        = sg_key
            create_new_sg = lookup(sg_value, "create_new_sg", true)
            eni_id        = eni
          }
        ]
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}

# ── EC2 attachments ───────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "ec2" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for instance_name in lookup(lookup(sg_value, "service_attachments", {}), "ec2_instances", []) : {
          key           = "${sg_key}-ec2-${instance_name}"
          sg_key        = sg_key
          create_new_sg = lookup(sg_value, "create_new_sg", true)
          eni_id        = data.aws_instance.specific_ec2[instance_name].network_interface_id
        }
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}

# ── VPC Endpoint attachments ──────────────────────────────────
resource "aws_network_interface_sg_attachment" "vpc_endpoints" {
  for_each = {
    for attachment_key, attachment_value in flatten([
      for sg_key, sg_value in var.security_groups : [
        for endpoint_id in lookup(lookup(sg_value, "service_attachments", {}), "vpc_endpoints", []) : [
          for idx, eni in data.aws_vpc_endpoint.specific_endpoints[endpoint_id].network_interface_ids : {
            key           = "${sg_key}-vpce-${endpoint_id}-${idx}"
            sg_key        = sg_key
            create_new_sg = lookup(sg_value, "create_new_sg", true)
            eni_id        = eni
          }
        ]
      ]
    ]) : attachment_value.key => attachment_value
  }

  security_group_id    = each.value.create_new_sg ? aws_security_group.sg[each.value.sg_key].id : data.aws_security_group.existing[each.value.sg_key].id
  network_interface_id = each.value.eni_id
}
