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
