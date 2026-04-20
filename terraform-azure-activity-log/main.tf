resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  for_each           = { for idx, sa in var.storage_account_id : idx => sa }
  name               = "${var.diagnostic_name}-${each.key}"
  target_resource_id = var.target_resource_id

  storage_account_id = each.value

  dynamic "enabled_log" {
    for_each = var.log_categories
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_action_group" "action_group" {
  count               = length(var.email_receivers) > 0 ? 1 : 0
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "activity_alert" {
  count               = length(var.email_receivers) > 0 ? 1 : 0
  name                = var.alert_name
  resource_group_name = var.resource_group_name
  scopes              = var.scopes
  description         = var.alert_description
  location            = var.location
  criteria {
    category       = var.alert_category
    operation_name = var.operation_name
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group[0].id
  }
}