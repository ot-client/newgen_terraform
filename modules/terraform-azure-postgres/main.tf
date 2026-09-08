resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = var.private_dns_zone_virtual_network_link_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
}


resource "azurerm_postgresql_flexible_server" "default" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.posgressversion
  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.private_dns.id
  administrator_login           = var.db_username
  administrator_password        = var.db_password
  public_network_access_enabled = var.public_network_access_enabled
  zone                          = var.postgres_zones
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled

  # HA: SameZone keeps standby in same zone; ZoneRedundant spreads across zones
  # Enabled only when high_availability_enabled = true
  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = var.mode
      standby_availability_zone = var.postgres_zones
    }
  }

  # Maintenance window: values driven from tfvars (client can change anytime)
  # day_of_week: 0=Sunday, 1=Monday ... 6=Saturday
  maintenance_window {
    day_of_week  = var.maintenance_window_day
    start_hour   = var.maintenance_window_hour
    start_minute = var.maintenance_window_minute
  }

  lifecycle {
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

## Diagnostic Settings: sends logs and metrics to
# Log Analytics Workspace and Storage Account

# Enabled only when enable_diagnostic_settings = true

# CIS #4 - Short-term diagnostic setting: all logs → 3 months retention (alllogs storage account)
resource "azurerm_monitor_diagnostic_setting" "postgres_diag_short" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "${var.name}-diag-short"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.enable_all_metrics ? [1] : []
    content {
      category = "AllMetrics"
    }
  }
}

# CIS #4 - Long-term audit diagnostic setting: audit logs → 18 months / 8 years retention (audit storage account)
resource "azurerm_monitor_diagnostic_setting" "postgres_diag_audit" {
  count              = var.enable_diagnostic_settings && var.audit_storage_account_id != null ? 1 : 0
  name               = "${var.name}-diag-audit"
  target_resource_id = azurerm_postgresql_flexible_server.default.id
  storage_account_id = var.audit_storage_account_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "db_params" {
  for_each   = var.db_parameters
  server_id  = azurerm_postgresql_flexible_server.default.id
  name       = each.key
  value      = each.value
}

# CIS #10 - Metric alerts for CPU, Memory and Storage
resource "azurerm_monitor_metric_alert" "postgres_alerts" {
  for_each            = var.enable_alerts && var.alert_action_group_id != null ? var.alert_rules : {}
  name                = "${var.name}-alert-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.default.id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = "GreaterThan"
    threshold        = each.value.threshold
  }

  action {
    action_group_id = var.alert_action_group_id
  }
}

# DB service up/down - activity log alert on server start and stop events
resource "azurerm_monitor_activity_log_alert" "postgres_service_health" {
  count               = var.enable_service_health_alert && var.alert_action_group_id != null ? 1 : 0
  name                = "${var.name}-service-health"
  resource_group_name = var.resource_group_name
  location            = var.activity_log_alert_location
  scopes              = [azurerm_postgresql_flexible_server.default.id]
  description         = "Alert on PostgreSQL Flexible Server start and stop events"

  criteria {
    resource_id    = azurerm_postgresql_flexible_server.default.id
    operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/restart/action"
    category       = "Administrative"
  }

  action {
    action_group_id = var.alert_action_group_id
  }
}