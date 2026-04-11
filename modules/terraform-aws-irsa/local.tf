locals {
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}
