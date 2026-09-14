output "action_group_ids" {
  description = "Map of action group logical key => resource ID"
  value       = { for k, ag in azurerm_monitor_action_group.this : k => ag.id }
}

output "action_group_names" {
  description = "Map of action group logical key => name"
  value       = { for k, ag in azurerm_monitor_action_group.this : k => ag.name }
}
