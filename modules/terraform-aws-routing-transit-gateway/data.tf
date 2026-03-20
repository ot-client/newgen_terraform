data "aws_ec2_transit_gateway" "existing_tgw" {
  id = var.tgw_id
}

data "aws_ec2_transit_gateway" "existing_tgw" {
  transit_gateway_id = "tgw-0be815d6e6c3d35c3"  # Replace with your Transit Gateway ID
}