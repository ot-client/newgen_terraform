# ############################################################
# # EC2 Instance
# ############################################################

# resource "aws_instance" "ec2" {
#   for_each = var.ec2_instances

#   ami           = each.value.ami_id
#   instance_type = each.value.instance_type
#   subnet_id     = each.value.subnet_id
#   vpc_security_group_ids = [
#     for sg_name in each.value.security_groups :
#     aws_security_group.sg[sg_name].id
#   ]
#   associate_public_ip_address = each.value.public_ip
#   key_name                    = aws_key_pair.instance_keys[each.key].key_name
#   iam_instance_profile        = lookup(each.value, "iam_instance_profile", null)

#   disable_api_termination = each.value.termination_protection
#   source_dest_check       = each.value.source_dest_check

#   root_block_device {
#     volume_size           = each.value.volume_size
#     volume_type           = each.value.volume_type
#     throughput            = each.value.throughput
#     encrypted             = each.value.encrypted_volume
#     delete_on_termination = each.value.delete_on_termination
    
#   }

#   tags = merge(
#     {
#       Name = each.key
#     },
#     local.common_tags,
#     each.value.tags
#   )
# }

# ############################################################
# # Additional Volume D
# ############################################################

# resource "aws_ebs_volume" "volume_d" {
#   for_each = var.ec2_instances

#   availability_zone = aws_instance.ec2[each.key].availability_zone
#   size              = each.value.volume_size
#   type              = each.value.volume_type
#   throughput        = each.value.throughput
#   encrypted         = each.value.encrypted_volume

#   tags = merge(
#     {
#       Name = "${each.key}-volume-d"
#     },
#     local.common_tags
#   )
# }

# resource "aws_volume_attachment" "attach_d" {
#   for_each = var.ec2_instances

#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.volume_d[each.key].id
#   instance_id = aws_instance.ec2[each.key].id
# }

# ############################################################
# # Additional Volume E
# ############################################################

# resource "aws_ebs_volume" "volume_e" {
#   for_each = var.ec2_instances

#   availability_zone = aws_instance.ec2[each.key].availability_zone
#   size              = each.value.volume_size
#   type              = each.value.volume_type
#   throughput        = each.value.throughput
#   encrypted         = each.value.encrypted_volume

#   tags = merge(
#     {
#       Name = "${each.key}-volume-e"
#     },
#     local.common_tags
#   )
# }

# resource "aws_volume_attachment" "attach_e" {
#   for_each = var.ec2_instances

#   device_name = "/dev/sdg"
#   volume_id   = aws_ebs_volume.volume_e[each.key].id
#   instance_id = aws_instance.ec2[each.key].id
# }

# ############################################################
# # Elastic IP (Optional)
# ############################################################

# resource "aws_eip" "eip" {
#   for_each = {
#     for k, v in var.ec2_instances :
#     k => v if v.enable_eip
#   }

#   instance = aws_instance.ec2[each.key].id
#   domain   = "vpc"

#   tags = merge(
#     {
#       Name = "${each.key}-eip"
#     },
#     local.common_tags
#   )
# }

# ############################################
# # Security Groups
# ############################################

# resource "aws_security_group" "sg" {
#   for_each = toset(var.security_groups)

#   name        = each.value
#   description = "Security Group ${each.value}"
#   vpc_id      = var.vpc_id

#   tags = merge(
#     {
#       Name = each.value
#     },
#     local.common_tags
#   )
# }

# resource "aws_security_group_rule" "security_rules" {

#   for_each = {
#     for pair in flatten([
#       for rule_key, rule_value in var.security_group_ports : [
#         for sg_key, sg_val in aws_security_group.sg : {
#           rule_name = rule_key
#           sg_key    = sg_key
#           sg_id     = sg_val.id
#           rule      = rule_value
#         }
#         if can(regex(rule_value.name_regex, sg_key))
#       ]
#     ]) : "${pair.rule_name}-${pair.sg_key}" => pair
#   }

#   type              = each.value.rule.type
#   from_port         = each.value.rule.from_port
#   to_port           = each.value.rule.to_port
#   protocol          = each.value.rule.protocol
#   cidr_blocks       = each.value.rule.cidr_blocks
#   security_group_id = each.value.sg_id
# }
# ###############################
# # RT Attach to ENI
# ##############################

# resource "aws_route" "private_default_to_firewall" {
#   for_each = toset(data.aws_route_tables.selected.ids)

#   route_table_id         = each.value
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id   = aws_instance.ec2[var.firewall_instance_key].primary_network_interface_id
# }

# #################################
# # Key Pairs
# #################################
# resource "tls_private_key" "instance_keys" {
#   for_each = var.ec2_instances

#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "instance_keys" {
#   for_each = var.ec2_instances

#   key_name   = each.value.key_name
#   public_key = tls_private_key.instance_keys[each.key].public_key_openssh

#   tags = merge(
#     {
#       Name = "${each.key}-key"
#     },
#     local.common_tags
#   )
# }

# resource "local_file" "pem_files" {
#   for_each = var.ec2_instances

#   filename        = "${path.root}/${each.value.key_name}.pem"
#   content         = tls_private_key.instance_keys[each.key].private_key_pem
#   file_permission = "0400"
# }

############################################################
# EC2 Instance
############################################################

resource "aws_instance" "ec2" {
  for_each = var.ec2_instances

  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [
    for sg_name in each.value.security_groups :
    aws_security_group.sg[sg_name].id
  ]
  associate_public_ip_address = each.value.public_ip
  key_name                    = aws_key_pair.instance_keys[each.key].key_name
  iam_instance_profile        = lookup(each.value, "iam_instance_profile", null)

  disable_api_termination = each.value.termination_protection
  source_dest_check       = each.value.source_dest_check

  # Updated to use root_block_device object
  root_block_device {
    volume_size           = each.value.root_block_device.size
    volume_type           = each.value.root_block_device.type
    throughput            = each.value.root_block_device.throughput
    iops                  = each.value.root_block_device.iops
    encrypted             = each.value.root_block_device.encrypted
    delete_on_termination = each.value.root_block_device.delete_on_termination
  }

  tags = merge(
    {
      Name = each.key
    },
    local.common_tags,
    each.value.tags
  )
}

############################################################
# Additional Volumes (Dynamic based on additional_volumes list)
############################################################

resource "aws_ebs_volume" "additional" {
  # Flatten to create one resource per instance per volume
  for_each = {
    for item in flatten([
      for instance_key, instance_value in var.ec2_instances : [
        for idx, vol in instance_value.additional_volumes : {
          key               = "${instance_key}-vol-${idx}"
          instance_key      = instance_key
          device_name       = vol.device_name
          size              = vol.size
          type              = vol.type
          throughput        = vol.throughput
          iops              = vol.iops
          encrypted         = vol.encrypted
          availability_zone = aws_instance.ec2[instance_key].availability_zone
        }
      ]
    ]) : item.key => item
  }

  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = each.value.type
  throughput        = each.value.throughput
  iops              = each.value.iops
  encrypted         = each.value.encrypted

  tags = merge(
    {
      Name = each.key
      DeviceName = each.value.device_name
    },
    local.common_tags
  )
}

resource "aws_volume_attachment" "additional" {
  for_each = aws_ebs_volume.additional

  device_name = each.value.tags_all["DeviceName"]  # Store device_name in tags for reference
  volume_id   = each.value.id
  instance_id = aws_instance.ec2[split("-vol-", each.key)[0]].id

  depends_on = [aws_ebs_volume.additional]
}

############################################################
# Elastic IP (Optional)
############################################################

resource "aws_eip" "eip" {
  for_each = {
    for k, v in var.ec2_instances :
    k => v if v.enable_eip
  }

  instance = aws_instance.ec2[each.key].id
  domain   = "vpc"

  tags = merge(
    {
      Name = "${each.key}-eip"
    },
    local.common_tags
  )
}

############################################
# Security Groups
############################################

resource "aws_security_group" "sg" {
  for_each = toset(var.security_groups)

  name        = each.value
  description = "Security Group ${each.value}"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = each.value
    },
    local.common_tags
  )
}

resource "aws_security_group_rule" "security_rules" {
  for_each = {
    for pair in flatten([
      for rule_key, rule_value in var.security_group_ports : [
        for sg_key, sg_val in aws_security_group.sg : {
          rule_name = rule_key
          sg_key    = sg_key
          sg_id     = sg_val.id
          rule      = rule_value
        }
        if can(regex(rule_value.name_regex, sg_key))
      ]
    ]) : "${pair.rule_name}-${pair.sg_key}" => pair
  }

  type              = each.value.rule.type
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  cidr_blocks       = each.value.rule.cidr_blocks
  security_group_id = each.value.sg_id
}

###############################
# RT Attach to ENI
##############################

resource "aws_route" "private_default_to_firewall" {
  for_each = toset(data.aws_route_tables.selected.ids)

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.ec2[var.firewall_instance_key].primary_network_interface_id
}

#################################
# Key Pairs
#################################

resource "tls_private_key" "instance_keys" {
  for_each = var.ec2_instances

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_keys" {
  for_each = var.ec2_instances

  key_name   = each.value.key_name
  public_key = tls_private_key.instance_keys[each.key].public_key_openssh

  tags = merge(
    {
      Name = "${each.key}-key"
    },
    local.common_tags
  )
}

resource "local_file" "pem_files" {
  for_each = var.ec2_instances

  filename        = "${path.root}/${each.value.key_name}.pem"
  content         = tls_private_key.instance_keys[each.key].private_key_pem
  file_permission = "0400"
}