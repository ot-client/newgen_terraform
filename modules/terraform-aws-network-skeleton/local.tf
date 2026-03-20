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

  subnet_ids_by_index = {
    for i, s in aws_subnet.subnets :
    i => s.id
  }

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



locals {
  nacl_config = {
    for name, subnet_indexes in var.nacl_subnet_map :
    name => {
      name       = name
      subnet_ids = [for i in subnet_indexes : local.subnet_ids_by_index[i]]

      ingress = [
        {
          rule_no    = 100
          protocol   = "-1"
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 0
          to_port    = 0
        }
      ]

      egress = [
        {
          rule_no    = 100
          protocol   = "-1"
          action     = "allow"
          cidr_block = "0.0.0.0/0"
          from_port  = 0
          to_port    = 0
        }
      ]
    }
  }
}


################### ROUTE TABLE #######################

locals {
  route_tables = {
    for name, subnet_indexes in var.route_table_subnet_map :
    name => {
      name       = name
      subnet_ids = [for i in subnet_indexes : local.subnet_ids_by_index[i]]
    }
  }
}

locals {
  route_table_associations = flatten([
    for rt_name, subnet_indexes in var.route_table_subnet_map : [
      for subnet_index in subnet_indexes : {
        rt_name      = rt_name
        subnet_index = subnet_index
      }
    ]
  ])
}
