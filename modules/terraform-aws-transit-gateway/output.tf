# output "vpc_attachment_ids" {
#   value = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachment : k => v.id }
# }

output "aws_ec2_transit_gateway_ids" {
  value = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachment : k => v.transit_gateway_id }
  description = "Map of VPC attachment names to their Transit Gateway IDs"
}


output "aws_ec2_transit_gateway_vpc_attachment_ids" {
  value = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachment : k => v.id }
  description = "Map of VPC attachment names to their IDs"
}