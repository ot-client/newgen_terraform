resource "aws_route" "tgw_routes" {
  for_each = toset(var.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = var.tgw_route_cidr_block
  transit_gateway_id     = data.aws_ec2_transit_gateway.existing_tgw.id
}
