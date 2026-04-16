locals {
  # Flatten: for each tgw_route entry, create one route per route_table_id
  route_entries = flatten([
    for route_key, route_val in var.tgw_routes : [
      for rt_id in route_val.route_table_ids : {
        key                  = "${route_key}-${rt_id}"
        route_table_id       = rt_id
        destination_cidr     = route_val.destination_cidr_block
        transit_gateway_id   = route_val.tgw_id
      }
    ]
  ])
}

resource "aws_route" "tgw_routes" {
  for_each = { for r in local.route_entries : r.key => r }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = each.value.transit_gateway_id
}
