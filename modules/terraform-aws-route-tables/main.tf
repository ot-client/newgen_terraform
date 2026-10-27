resource "aws_route_table" "rt" {
  for_each = toset(var.route_table_names)

  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = each.key })
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.rt[var.igw_rt].id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = var.igw_id
}

# ENI routes — accepts instance_id, fetches ENI automatically
data "aws_instance" "instance_routes" {
  for_each    = var.instance_routes
  instance_id = each.value.instance_id
}

resource "aws_route" "instance_routes" {
  for_each = var.instance_routes

  route_table_id         = aws_route_table.rt[each.value.route_table_name].id
  destination_cidr_block = each.value.destination_cidr_block
  network_interface_id   = data.aws_instance.instance_routes[each.key].network_interface_id
}

# NAT Gateway routes
resource "aws_route" "nat_routes" {
  for_each = var.nat_routes

  route_table_id         = aws_route_table.rt[each.value.route_table_name].id
  destination_cidr_block = each.value.destination_cidr_block
  nat_gateway_id         = each.value.nat_gateway_id
}

# Transit Gateway routes
resource "aws_route" "tgw_routes" {
  for_each = var.tgw_routes

  route_table_id         = aws_route_table.rt[each.value.route_table_name].id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = each.value.transit_gateway_id
}

# VPC Peering routes
resource "aws_route" "peering_routes" {
  for_each = var.peering_routes

  route_table_id            = aws_route_table.rt[each.value.route_table_name].id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

# VGW Route Propagation
resource "aws_vpn_gateway_route_propagation" "propagation" {
  for_each = var.propagating_vgws

  route_table_id = aws_route_table.rt[each.value.route_table_name].id
  vpn_gateway_id = each.value.vpn_gateway_id
}

resource "aws_route_table_association" "rt_assoc" {
  for_each = {
    for assoc in flatten([
      for rt_name, subnet_indexes in var.route_table_subnet_map : [
        for idx in subnet_indexes : {
          key       = "${rt_name}-${idx}"
          rt_name   = rt_name
          subnet_id = var.subnet_ids[idx]
        }
      ]
    ]) : assoc.key => assoc
  }

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.rt[each.value.rt_name].id
}
