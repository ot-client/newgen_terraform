locals {
  base_name   = lookup(var.tags, "Name", "")
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}

# ─── Security Group Rule Locals ───────────────────────────────────────────────

locals {
  ingress_cidr_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for rule in sg.ingress_rules : [
        for cidr in rule.cidr_blocks : {
          sg_name     = sg_name
          port        = rule.port
          cidr        = cidr
          description = rule.description
        }
      ] if length(rule.cidr_blocks) > 0
    ]
  ])

  ingress_sg_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for rule in sg.ingress_rules : {
        sg_name      = sg_name
        port         = rule.port
        source_sg_id = rule.source_sg_id
        description  = rule.description
      } if rule.source_sg_id != ""
    ]
  ])

  egress_cidr_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for rule in sg.egress_rules : [
        for cidr in rule.cidr_blocks : {
          sg_name     = sg_name
          port        = rule.port
          cidr        = cidr
          description = rule.description
        }
      ]
    ] if !sg.egress_allow_all
  ])
}

# ─── EFS Config Resolution ────────────────────────────────────────────────────

locals {
  efs_configs_resolved = {
    for k, v in var.efs_configs : k => merge(v, {
      mount_targets = [
        for mt in v.mount_targets : {
          subnet_id       = can(regex("^subnet-", mt.subnet_id)) ? mt.subnet_id : var.subnet_ids[mt.subnet_id]
          security_groups = [for sg_name in mt.security_group_refs : aws_security_group.efs[sg_name].id]
        }
      ]
    })
  }
}

# ─── Mount Target Flattening ──────────────────────────────────────────────────

locals {
  mount_targets = flatten([
    for efs_key, efs_val in local.efs_configs_resolved : [
      for mt in efs_val.mount_targets : {
        efs_key         = efs_key
        subnet_id       = mt.subnet_id
        security_groups = mt.security_groups
      }
    ]
  ])
}

# ─── Access Point Flattening ──────────────────────────────────────────────────

locals {
  access_points = flatten([
    for efs_key, efs_val in local.efs_configs_resolved : [
      for ap_key, ap_val in efs_val.access_points : {
        efs_key = efs_key
        ap_key  = ap_key
        config  = ap_val
      }
    ]
  ])
}
