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
  name                          = "${var.name}-server"
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
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled

  # HA: SameZone keeps standby in same zone; ZoneRedundant spreads across zones
  # Enabled only when high_availability_enabled = true
  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = "SameZone"
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
    { "Name" = "${var.name}-server" },
    var.tags
  )
}

# Diagnostic Settings: sends logs & metrics to both Log Analytics and Storage Account
# Client requirement: logs in Log Analytics + Storage Account
# Enabled only when enable_diagnostic_settings = true in tfvars
resource "azurerm_monitor_diagnostic_setting" "postgres_diag" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_log {
    category = "PostgreSQLFlexDatabaseXacts"
  }
}
