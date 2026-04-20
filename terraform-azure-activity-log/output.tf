output "action_group_id" {
  value = length(azurerm_monitor_action_group.action_group) > 0 ? azurerm_monitor_action_group.action_group[0].id : null
}

output "alert_id" {
  value = length(azurerm_monitor_activity_log_alert.activity_alert) > 0 ? azurerm_monitor_activity_log_alert.activity_alert[0].id : null
}

output "diagnostic_id" {
  value = azurerm_monitor_diagnostic_setting.activity_log.id
}