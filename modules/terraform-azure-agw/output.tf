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

output "diag_storage_account_id" {
  description = "The ID of the diagnostics storage account"
  value       = var.diag_storage_account_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}
