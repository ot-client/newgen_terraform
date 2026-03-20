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

resource "aws_security_group_rule" "nfs_ingress" {
  count             = var.create_security_group ? 1 : 0
  description       = "Allow NFS traffic"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = var.nfs_ingress_cidr_blocks
  security_group_id = aws_security_group.efs_sg[0].id
}

# Self-referencing rule — kept from Nikita's module
resource "aws_security_group_rule" "nfs_ingress_self" {
  count             = var.create_security_group && var.enable_self_referencing_sg_rule ? 1 : 0
  description       = "Allow NFS from same SG"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.efs_sg[0].id
}

resource "aws_security_group_rule" "nfs_egress" {
  count             = var.create_security_group ? 1 : 0
  description       = "Allow all egress"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
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
