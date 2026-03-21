output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage_account.id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "private_endpoint_ip_address" {
  description = "The IP address of the private endpoint."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.private_endpoint[0].private_service_connection[0].private_ip_address : null
}
