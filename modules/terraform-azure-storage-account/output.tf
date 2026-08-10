output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}


output "file_share_ids" {
  description = "Map of file share names to their resource IDs."
  value       = { for k, v in azurerm_storage_share.file_share : k => v.id }
}