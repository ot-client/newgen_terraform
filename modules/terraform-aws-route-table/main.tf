locals {
  common_tags = { for k, v in var.tags : k => v if k != "Name" }

  routes = merge([
    for rt_name, rt in var.route_tables : {
      for r in rt.routes : "${rt_name}|${r.cidr_block}" => merge(r, { rt_name = rt_name })
    }
  ]...)

  associations = merge([
    for rt_name, rt in var.route_tables : {
      for s in rt.subnet_ids : "${rt_name}|${s}" => { rt_name = rt_name, subnet_id = s }
    }
  ]...)
}

resource "aws_route_table" "rt" {
  for_each = var.route_tables
  vpc_id   = var.vpc_id

  tags = merge({ Name = each.key }, local.common_tags)
}

resource "aws_route" "routes" {
  for_each = local.routes

  route_table_id            = aws_route_table.rt[each.value.rt_name].id
  destination_cidr_block    = each.value.cidr_block
  gateway_id                = each.value.gateway_id
  nat_gateway_id            = each.value.nat_gateway_id
  transit_gateway_id        = each.value.transit_gateway_id
  vpc_endpoint_id           = each.value.vpc_endpoint_id
  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

resource "aws_route_table_association" "assoc" {
  for_each = local.associations

  route_table_id = aws_route_table.rt[each.value.rt_name].id
  subnet_id      = each.value.subnet_id
}
