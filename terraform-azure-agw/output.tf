output "agw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "agw_name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "The public IP address of the AGW"
  value       = azurerm_public_ip.pip.ip_address
}
