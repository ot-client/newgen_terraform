resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  for_each = { for vpc in var.vpc_attachments : vpc.name => vpc }

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = data.aws_ec2_transit_gateway.existing_tgw.id
  vpc_id             = each.value.vpc_id

  dns_support                            = each.value.dns_support
  ipv6_support                           = each.value.ipv6_support
  transit_gateway_default_route_table_association = each.value.associate_with_tgw_route_table
  transit_gateway_default_route_table_propagation = each.value.propagate_to_tgw_route_table

#     tags = merge(
#     {
#       Name = "${local.base_name}-${each.value.name}-tgw-attach"
#     },
#     local.common_tags
#   )

 }
