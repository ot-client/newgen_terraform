output "transit_gateway_id" {
  description = "ID of the existing Transit Gateway"
  value       = data.aws_ec2_transit_gateway.existing_tgw.id
}

output "transit_gateway_arn" {
  description = "ARN of the existing Transit Gateway"
  value       = data.aws_ec2_transit_gateway.existing_tgw.arn
}

output "transit_gateway_owner_id" {
  description = "Owner ID of the existing Transit Gateway"
  value       = data.aws_ec2_transit_gateway.existing_tgw.owner_id
}

output "vpc_attachment_ids" {
  description = "Map of VPC attachment names to their IDs"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachment : k => v.id }
}

output "vpc_attachment_details" {
  description = "Complete details of all VPC attachments"
  value = {
    for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachment : k => {
      id                 = v.id
      vpc_id            = v.vpc_id
      subnet_ids        = v.subnet_ids
      dns_support       = v.dns_support
      ipv6_support      = v.ipv6_support
      
    }
  }
}
