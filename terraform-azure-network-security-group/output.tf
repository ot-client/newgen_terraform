output "nsg_ids" {
  value = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "nsg_names" {
  value = { for k, v in azurerm_network_security_group.nsg : k => v.name }
}

output "flow_log_ids" {
  description = "Map of VNet Flow Log IDs"
  value       = var.enable_flow_logs ? { for k, v in azurerm_network_watcher_flow_log.nsg_flow_log : k => v.id } : {}
}
