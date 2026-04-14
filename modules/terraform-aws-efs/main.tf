# ─── Security Groups ──────────────────────────────────────────────────────────

resource "aws_security_group" "efs" {
  for_each    = var.security_groups
  name        = each.key
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = each.key })
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = { for r in local.ingress_cidr_rules : "${r.sg_name}-${r.port}-${r.cidr}" => r }
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr]
  description       = each.value.description
  security_group_id = aws_security_group.efs[each.value.sg_name].id
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each                 = { for r in local.ingress_sg_rules : "${r.sg_name}-${r.port}-${r.source_sg_id}" => r }
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = each.value.source_sg_id
  description              = each.value.description
  security_group_id        = aws_security_group.efs[each.value.sg_name].id
}

resource "aws_security_group_rule" "egress_all" {
  for_each          = { for sg_name, sg in var.security_groups : sg_name => sg if sg.egress_allow_all }
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs[each.key].id
}

resource "aws_security_group_rule" "egress_custom" {
  for_each          = { for r in local.egress_cidr_rules : "${r.sg_name}-${r.port}-${r.cidr}" => r }
  type              = "egress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr]
  description       = each.value.description
  security_group_id = aws_security_group.efs[each.value.sg_name].id
}

# ─── EFS File Systems ─────────────────────────────────────────────────────────

resource "aws_efs_file_system" "main" {
  for_each = local.efs_configs_resolved

  creation_token                  = each.key
  performance_mode                = each.value.performance_mode
  throughput_mode                 = each.value.throughput_mode
  provisioned_throughput_in_mibps = try(each.value.provisioned_throughput_in_mibps, null)
  encrypted                       = each.value.encrypted
  kms_key_id                      = try(each.value.kms_key_id, null)

  dynamic "lifecycle_policy" {
    for_each = each.value.lifecycle_policies
    content {
      transition_to_ia                    = lifecycle_policy.value.transition_to_ia
      transition_to_archive               = try(lifecycle_policy.value.transition_to_archive, null)
      transition_to_primary_storage_class = try(lifecycle_policy.value.transition_to_primary_storage_class, null)
    }
  }

  tags = merge(local.common_tags, try(each.value.tags, {}), { Name = each.key })
}

resource "aws_efs_backup_policy" "backup" {
  for_each = {
    for k, v in local.efs_configs_resolved : k => v
    if v.automatic_backups != null
  }

  file_system_id = aws_efs_file_system.main[each.key].id

  backup_policy {
    status = each.value.automatic_backups
  }
}

# ─── Mount Targets ────────────────────────────────────────────────────────────

resource "aws_efs_mount_target" "target" {
  for_each = {
    for mt in local.mount_targets : "${mt.efs_key}.${mt.subnet_id}" => mt
  }

  file_system_id  = aws_efs_file_system.main[each.value.efs_key].id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}

# ─── Access Points ────────────────────────────────────────────────────────────

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
      secondary_gids = try(posix_user.value.secondary_gids, null)
    }
  }

  tags = merge(local.common_tags, try(var.efs_configs[each.value.efs_key].tags, {}), {
    Name = "${each.value.efs_key}-${each.value.ap_key}"
  })
}
