output "agw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "agw_name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.pip.ip_address
}

output "diag_storage_account_id" {
  description = "The diagnostics storage account ID"
  value       = var.diag_storage_account_id
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.law.id
}