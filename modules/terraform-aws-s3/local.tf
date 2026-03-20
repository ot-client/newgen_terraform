locals {
  create_bucket     = var.create_bucket
  create_bucket_acl = var.acl != null && var.acl != "null"
  attach_policy     = var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_iam_policy || var.attach_cloudtrail_policy
  cors_rules        = var.cors_rules

  # base_name is derived from the "Name" key in var.tags (set per-resource in tfvars)
  base_name = lookup(var.tags, "Name", "")

  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}
