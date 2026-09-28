locals {
  create_bucket     = var.create_bucket
  create_bucket_acl = var.acl != null && var.acl != "null"
  attach_policy     = var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_iam_policy || var.attach_cloudtrail_policy || var.bucket_policy != null
  cors_rules        = var.cors_rules

  versioning_status = var.versioning.enabled ? "Enabled" : "Suspended"

  # base_name is derived from the "Name" key in var.tags (set per-resource in tfvars)
  base_name = lookup(var.tags, "Name", "")

  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }

  # Replication
  enabled_replication_rules = [for r in var.replication_rules : r if r.enabled]
  provided_iam_role_arn     = length(local.enabled_replication_rules) > 0 ? try(local.enabled_replication_rules[0].iam_role_arn, null) : null
  create_replication_role   = local.create_bucket && length(local.enabled_replication_rules) > 0 && local.provided_iam_role_arn == null
}
