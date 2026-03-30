# ACR
output "acr_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the container registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "The login server URL of the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "sku" {
  description = "The SKU of the container registry"
  value       = azurerm_container_registry.acr.sku
}

output "admin_enabled" {
  description = "Whether admin user is enabled (false = RBAC enforced)"
  value       = azurerm_container_registry.acr.admin_enabled
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  value       = azurerm_container_registry.acr.public_network_access_enabled
}

# Private Endpoint
output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = var.subnet_id != null ? azurerm_private_endpoint.acr_private_endpoint[0].id : null
}

output "private_endpoint_name" {
  description = "The name of the private endpoint"
  value       = var.subnet_id != null ? azurerm_private_endpoint.acr_private_endpoint[0].name : null
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = var.subnet_id != null ? azurerm_private_endpoint.acr_private_endpoint[0].private_service_connection[0].private_ip_address : null
}

output "private_endpoint_fqdn" {
  description = "The FQDN of the private endpoint (from custom DNS config)"
  value       = var.subnet_id != null ? azurerm_private_endpoint.acr_private_endpoint[0].custom_dns_configs[0].fqdn : null
}
