output "instance_id" {
  description = "Firewall EC2 instance ID."
  value       = aws_instance.firewall.id
}

output "instance_arn" {
  description = "Firewall EC2 instance ARN."
  value       = aws_instance.firewall.arn
}

output "primary_network_interface_id" {
  description = "Primary network interface ID for route-table targets."
  value       = aws_instance.firewall.primary_network_interface_id
}

output "private_ip" {
  description = "Private IP address of the firewall EC2 instance."
  value       = aws_instance.firewall.private_ip
}

output "new_eip_allocation_id" {
  description = "Allocation ID of the newly created EIP."
  value       = try(aws_eip.new_firewall_eip[0].allocation_id, null)
}

output "new_eip_public_ip" {
  description = "Public IP address of the newly created EIP."
  value       = try(aws_eip.new_firewall_eip[0].public_ip, null)
}

output "existing_eip_allocation_id" {
  description = "Existing EIP allocation ID associated with the firewall EC2 instance."
  value       = var.existing_eip_allocation_id != "" ? var.existing_eip_allocation_id : null
}

output "existing_eip_association_id" {
  description = "Association ID for the existing EIP attached to the firewall EC2 instance."
  value       = try(aws_eip_association.existing_firewall_eip[0].id, null)
}

output "effective_eip_allocation_id" {
  description = "EIP allocation ID currently managed by this module."
  value       = var.existing_eip_allocation_id != "" ? var.existing_eip_allocation_id : try(aws_eip.new_firewall_eip[0].allocation_id, null)
}

output "route_ids" {
  description = "Route IDs created for firewall route-table entries."
  value       = { for key, route in aws_route.firewall_route_table_entries : key => route.id }
}

output "key_pair_name" {
  description = "Key pair name used by the firewall EC2 instance."
  value       = var.create_key_pair ? aws_key_pair.firewall_key_pair[0].key_name : var.key_name
}

output "private_key_path" {
  description = "Local private key path when a key is generated and written."
  value       = var.create_key_pair && var.private_key_output_path != "" ? var.private_key_output_path : null
}
