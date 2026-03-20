data "aws_ec2_transit_gateway" "existing_tgw" {
  id = var.tgw_id
}