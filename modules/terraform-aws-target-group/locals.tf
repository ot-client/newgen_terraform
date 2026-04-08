locals {
  base_name   = lookup(var.tags, "Name", "")
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}
