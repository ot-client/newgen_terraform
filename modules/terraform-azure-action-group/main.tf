resource "azurerm_monitor_action_group" "this" {
  for_each = var.action_groups

  name                = each.value.name
  resource_group_name = var.resource_group_name
  short_name          = each.value.short_name
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = each.value.email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
}
