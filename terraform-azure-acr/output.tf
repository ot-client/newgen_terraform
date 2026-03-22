output "acr_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.acr.id
}

output "login_server" {
  description = "The login server for the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "private_endpoint_ip" {
  description = "The IP address of the Private Endpoint"
  value       = var.subnet_id != null ? azurerm_private_endpoint.acr_private_endpoint[0].private_service_connection[0].private_ip_address : null
}
