resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  for_each = { for vpc in var.attachment_name : vpc.name => vpc }

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = data.aws_ec2_transit_gateway.existing_tgw.id
  vpc_id             = each.value.vpc_id

  dns_support                            = each.value.dns_support
  ipv6_support                           = each.value.ipv6_support

 }
