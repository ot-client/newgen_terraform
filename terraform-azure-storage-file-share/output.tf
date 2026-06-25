output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_file_endpoint" {
  description = "The primary file service endpoint."
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "file_share_ids" {
  description = "Map of file share names to their resource IDs."
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}
