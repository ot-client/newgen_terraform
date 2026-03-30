# ─── Security Group ───────────────────────────────────────────────────────────

resource "aws_security_group" "efs_sg" {
  count       = var.create_security_group ? 1 : 0
  name        = var.security_group_name
  description = "Security group for EFS file systems"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = var.security_group_name
  })
}

locals {
  # One entry per (rule, cidr) pair — CIDR-based ingress
  ingress_cidr_rules = var.create_security_group ? flatten([
    for rule in var.ingress_rules : [
      for cidr in rule.cidr_blocks : {
        port        = rule.port
        cidr        = cidr
        description = rule.description
      }
    ] if length(rule.cidr_blocks) > 0
  ]) : []

  # One entry per rule where source_sg_id is set — SG-source ingress
  ingress_sg_rules = var.create_security_group ? [
    for rule in var.ingress_rules : {
      port         = rule.port
      source_sg_id = rule.source_sg_id
      description  = rule.description
    } if rule.source_sg_id != ""
  ] : []

  # Flattened egress rules — used only when egress_allow_all = false
  egress_cidr_rules = var.create_security_group && !var.egress_allow_all ? flatten([
    for rule in var.egress_rules : [
      for cidr in rule.cidr_blocks : {
        port        = rule.port
        cidr        = cidr
        description = rule.description
      }
    ]
  ]) : []
}

# Ingress: CIDR-based
resource "aws_security_group_rule" "ingress_cidr" {
  count             = length(local.ingress_cidr_rules)
  type              = "ingress"
  from_port         = local.ingress_cidr_rules[count.index].port
  to_port           = local.ingress_cidr_rules[count.index].port
  protocol          = "tcp"
  cidr_blocks       = [local.ingress_cidr_rules[count.index].cidr]
  description       = local.ingress_cidr_rules[count.index].description
  security_group_id = aws_security_group.efs_sg[0].id
}

# Ingress: Source SG-based
resource "aws_security_group_rule" "ingress_sg" {
  count                    = length(local.ingress_sg_rules)
  type                     = "ingress"
  from_port                = local.ingress_sg_rules[count.index].port
  to_port                  = local.ingress_sg_rules[count.index].port
  protocol                 = "tcp"
  source_security_group_id = local.ingress_sg_rules[count.index].source_sg_id
  description              = local.ingress_sg_rules[count.index].description
  security_group_id        = aws_security_group.efs_sg[0].id
}

# Egress: allow-all (default when egress_allow_all = true)
resource "aws_security_group_rule" "egress_all" {
  count             = var.create_security_group && var.egress_allow_all ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_sg[0].id
}

# Egress: custom rules (used when egress_allow_all = false)
resource "aws_security_group_rule" "egress_custom" {
  count             = length(local.egress_cidr_rules)
  type              = "egress"
  from_port         = local.egress_cidr_rules[count.index].port
  to_port           = local.egress_cidr_rules[count.index].port
  protocol          = "tcp"
  cidr_blocks       = [local.egress_cidr_rules[count.index].cidr]
  description       = local.egress_cidr_rules[count.index].description
  security_group_id = aws_security_group.efs_sg[0].id
}

# ─── New EFS File Systems ──────────────────────────────────────────────────────

resource "aws_efs_file_system" "main" {
  for_each = var.efs_configs

  creation_token                  = each.key
  performance_mode                = each.value.performance_mode
  throughput_mode                 = each.value.throughput_mode
  provisioned_throughput_in_mibps = each.value.provisioned_throughput_in_mibps
  encrypted                       = each.value.encrypted
  kms_key_id                      = each.value.kms_key_id

  dynamic "lifecycle_policy" {
    for_each = each.value.lifecycle_policies
    content {
      transition_to_ia                    = lifecycle_policy.value.transition_to_ia
      transition_to_archive               = lifecycle_policy.value.transition_to_archive
      transition_to_primary_storage_class = lifecycle_policy.value.transition_to_primary_storage_class
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name    = each.key
    }
  )
}

resource "aws_efs_backup_policy" "backup" {
  for_each = {
    for k, v in var.efs_configs : k => v
    if v.automatic_backups != null
  }

  file_system_id = aws_efs_file_system.main[each.key].id

  backup_policy {
    status = each.value.automatic_backups
  }
}

# ─── Mount Targets (new EFS) ──────────────────────────────────────────────────

locals {
  mount_targets = flatten([
    for efs_key, efs_val in var.efs_configs : [
      for mt in efs_val.mount_targets : {
        efs_key         = efs_key
        subnet_id       = mt.subnet_id
        security_groups = mt.security_groups
      }
    ]
  ])
}

resource "aws_efs_mount_target" "target" {
  for_each = {
    for mt in local.mount_targets : "${mt.efs_key}.${mt.subnet_id}" => mt
  }

  file_system_id = aws_efs_file_system.main[each.value.efs_key].id
  subnet_id      = each.value.subnet_id
  security_groups = var.create_security_group ? distinct(
    concat(each.value.security_groups, [aws_security_group.efs_sg[0].id])
  ) : each.value.security_groups
}

# ─── Access Points (new EFS) ──────────────────────────────────────────────────

locals {
  access_points = flatten([
    for efs_key, efs_val in var.efs_configs : [
      for ap_key, ap_val in efs_val.access_points : {
        efs_key = efs_key
        ap_key  = ap_key
        config  = ap_val
      }
    ]
  ])
}

resource "aws_efs_access_point" "ap" {
  for_each = {
    for ap in local.access_points : "${ap.efs_key}.${ap.ap_key}" => ap
  }

  file_system_id = aws_efs_file_system.main[each.value.efs_key].id

  root_directory {
    path = each.value.config.path

    dynamic "creation_info" {
      for_each = each.value.config.creation_info != null ? [each.value.config.creation_info] : []
      content {
        owner_gid   = creation_info.value.owner_gid
        owner_uid   = creation_info.value.owner_uid
        permissions = creation_info.value.permissions
      }
    }
  }

  dynamic "posix_user" {
    for_each = each.value.config.posix_user != null ? [each.value.config.posix_user] : []
    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }

  tags = merge(
    local.common_tags,
    var.efs_configs[each.value.efs_key].tags,
    {
      Name    = "${each.value.efs_key}-${each.value.ap_key}"
    }
  )
}

# ─── Existing EFS Volumes (Nikita's pattern) ──────────────────────────────────

data "aws_efs_file_system" "existing" {
  count          = var.additional_existing_efs_volumes != null ? length(var.additional_existing_efs_volumes) : 0
  file_system_id = var.additional_existing_efs_volumes[count.index].file_system_id
}

resource "aws_efs_mount_target" "existing" {
  count          = var.add_subnet_efs_network ? length(var.additional_existing_efs_volumes) : 0
  file_system_id = var.additional_existing_efs_volumes[count.index].file_system_id
  subnet_id      = var.additional_existing_efs_volumes[count.index].subnet_id
  security_groups = var.create_security_group ? distinct(
    concat(var.external_security_group_ids, [aws_security_group.efs_sg[0].id])
  ) : var.external_security_group_ids
}

# ─── User-Data Templates ──────────────────────────────────────────────────────

# User-data for new EFS volumes (keyed by efs_configs key)
# data "template_file" "efs_user_data" {
#   for_each = {
#    for k, v in var.efs_configs : k => v
#    if v.mount_point != null
#  }
#
#  template = file("${path.module}/efs-user-data.sh.tpl")
#  vars = {
#    efs_dns_name    = aws_efs_file_system.main[each.key].dns_name
#    efs_mount_point = each.value.mount_point
#  }
# }

# User-data for existing EFS volumes
# data "template_file" "existing_efs_user_data" {
#  count    = var.additional_existing_efs_volumes != null ? length(var.additional_existing_efs_volumes) : 0
#  template = file("${path.module}/efs-user-data.sh.tpl")
#  vars = {
#    efs_dns_name    = data.aws_efs_file_system.existing[count.index].dns_name
#    efs_mount_point = var.additional_existing_efs_volumes[count.index].mount_point
#  }
# }
