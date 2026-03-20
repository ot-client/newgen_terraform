resource "aws_vpc_endpoint" "this" {
  for_each = var.endpoints

  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.type

  route_table_ids     = each.value.type == "Gateway" ? try(each.value.route_table_ids, null) : null
  subnet_ids          = each.value.type == "Interface" ? try(each.value.subnet_ids, null) : null
  security_group_ids  = each.value.type == "Interface" ? try(each.value.security_group_ids, null) : null
  private_dns_enabled = each.value.type == "Interface" ? try(each.value.private_dns, true) : null

  tags = merge(
    { Name = each.key },
    local.common_tags
  )
}
