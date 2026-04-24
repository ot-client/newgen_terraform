output "workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics.id
}

output "workspace_name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics.name
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
  sensitive   = true
}
