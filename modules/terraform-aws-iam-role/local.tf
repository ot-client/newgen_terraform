locals {
  role_names = {
    for role in keys(var.roles) :
    role => role
  }

  policy_names = {
    for policy in keys(var.custom_policies) :
    policy => policy
  }

  managed_policy_attachments = flatten([
    for role, data in var.roles : [
      for arn in data.managed_policy_arns : {
        key  = "${role}:${arn}"
        role = role
        arn  = arn
      }
    ]
  ])

  managed_policy_attachments_map = {
    for item in local.managed_policy_attachments :
    item.key => item
  }

  custom_policy_attachments = flatten([
    for role, data in var.roles : [
      for policy in data.custom_policy_names : {
        key    = "${role}:${policy}"
        role   = role
        policy = policy
      }
    ]
  ])

  custom_policy_attachments_map = {
    for item in local.custom_policy_attachments :
    item.key => item
  }

  # base_name is derived from the "Name" key in var.tags (set per-resource in tfvars)
  base_name = lookup(var.tags, "Name", "")

  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}
