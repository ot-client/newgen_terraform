output "instance_id" {
  description = "Firewall EC2 instance ID."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "Firewall EC2 instance ARN."
  value       = aws_instance.this.arn
}

output "primary_network_interface_id" {
  description = "Primary network interface ID for route-table targets."
  value       = aws_instance.this.primary_network_interface_id
}

output "private_ip" {
  description = "Private IP address of the firewall EC2 instance."
  value       = aws_instance.this.private_ip
}

output "new_eip_allocation_id" {
  description = "Allocation ID of the newly created EIP."
  value       = try(aws_eip.this[0].allocation_id, null)
}

output "new_eip_public_ip" {
  description = "Public IP address of the newly created EIP."
  value       = try(aws_eip.this[0].public_ip, null)
}

output "route_ids" {
  description = "Route IDs created for firewall route-table entries."
  value       = { for key, route in aws_route.firewall_routes : key => route.id }
}

output "key_pair_name" {
  description = "Key pair name used by the firewall EC2 instance."
  value       = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name
}

output "private_key_path" {
  description = "Local private key path when a key is generated and written."
  value       = var.create_key_pair && var.private_key_output_path != "" ? var.private_key_output_path : null
}
