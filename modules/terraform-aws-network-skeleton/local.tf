locals {
  # base_name is derived from the "Name" key in var.tags (set per-resource in tfvars)
  base_name = lookup(var.tags, "Name", "")

  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }

  # # Only for VPC
  # vpc_tags = merge(
  #   var.tags,
  #   {
  #     Customer-Code = var.vpc_tags
  #   }
  # )

  # # Only for Route Tables
  # route_table_tags = merge(
  #   var.tags,
  #   {
  #     CC = var.route_table_tags
  #   }
  # )

  # # Only for Subnets
  # subnet_tags = merge(
  #   var.tags,
  #   {
  #     Project = var.subnet_tags
  #   }
  # )

  # # Only for Internet Gateway
  # igw_tags = merge(
  #   var.tags,
  #   {
  #     CC-Project = var.igw_tags
  #   }
  # )

  subnets = [
    for i in range(length(var.subnet_names)) : {
      name  = var.subnet_names[i]
      cidr  = var.subnet_cidrs[i]
      az    = var.subnet_azs[i]
      index = i
    }
  ]

  # Single source of truth
  all_subnet_ids = aws_subnet.subnets[*].id

  application_subnet_ids = [
    for i, subnet in aws_subnet.subnets :
    subnet.id if can(regex("(?i)application", var.subnet_names[i]))
  ]

  database_subnet_ids = [
    for i, subnet in aws_subnet.subnets :
    subnet.id if can(regex("(?i)database", var.subnet_names[i]))
  ]

  selected_subnet_ids = (
    var.ec2_endpoint_type == "Interface" ? local.all_subnet_ids : null
  )
}
