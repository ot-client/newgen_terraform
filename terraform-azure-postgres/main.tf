resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name               = var.private_dns_zone_virtual_network_link_name
  private_dns_zone_id = azurerm_private_dns_zone.private_dns.id
  virtual_network_id = var.virtual_network_id
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

  # Maintenance window: disabled default Sunday 8:30 AM IST schedule
  # Set to custom window or disable by setting enabled = false
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

# PostgreSQL Server Configurations - Client Requirements
resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_duration" {
  name      = "log_duration"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_min_duration_statement" {
  name      = "log_min_duration_statement"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "500"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "mod"
}

resource "azurerm_postgresql_flexible_server_configuration" "shared_preload_libraries" {
  name      = "shared_preload_libraries"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "pg_cron,pg_stat_statements,pgaudit"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_stat_statements_max" {
  name      = "pg_stat_statements.max"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "2147483646"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_stat_statements_track" {
  name      = "pg_stat_statements.track"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "TOP"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_stat_statements_track_utility" {
  name      = "pg_stat_statements.track_utility"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_line_prefix" {
  name      = "log_line_prefix"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h"
}

resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log_client" {
  name      = "pgaudit.log_client"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "azure_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "pgaudit,amcheck"
}

# Diagnostic Settings: sends logs & metrics to both Log Analytics and Storage Account
# Client requirement: logs in Log Analytics + Storage Account
# Enabled only when enable_diagnostic_settings = true in tfvars
resource "azurerm_monitor_diagnostic_setting" "postgres_diag" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Audit Storage Account - 18 months retention
resource "azurerm_storage_account" "audit_storage" {
  count                    = var.enable_audit_storage ? 1 : 0
  name                     = var.audit_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  tags = var.tags
}

# Audit Storage Lifecycle Management - 18 months (547 days)
resource "azurerm_storage_management_policy" "audit_retention" {
  count              = var.enable_audit_storage ? 1 : 0
  storage_account_id = azurerm_storage_account.audit_storage[0].id

  rule {
    name    = "audit-retention-18months"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 547
      }
    }
  }
}

# All Logs Storage Account - 3 months retention
resource "azurerm_storage_account" "logs_storage" {
  count                    = var.enable_logs_storage ? 1 : 0
  name                     = var.logs_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Logs Storage Lifecycle Management - 3 months (90 days)
resource "azurerm_storage_management_policy" "logs_retention" {
  count              = var.enable_logs_storage ? 1 : 0
  storage_account_id = azurerm_storage_account.logs_storage[0].id

  rule {
    name    = "logs-retention-3months"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}

# Diagnostic Settings for Audit Storage
resource "azurerm_monitor_diagnostic_setting" "postgres_audit" {
  count                      = var.enable_audit_storage ? 1 : 0
  name                       = "${var.name}-audit-diagnostics"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  storage_account_id         = azurerm_storage_account.audit_storage[0].id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for All Logs Storage
resource "azurerm_monitor_diagnostic_setting" "postgres_all_logs" {
  count                      = var.enable_logs_storage ? 1 : 0
  name                       = "${var.name}-all-logs-diagnostics"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  storage_account_id         = azurerm_storage_account.logs_storage[0].id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Alerts - CPU Utilization
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${var.name}-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.default.id]
  description         = "Alert when CPU exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# Alerts - Memory Utilization
resource "azurerm_monitor_metric_alert" "memory_alert" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${var.name}-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.default.id]
  description         = "Alert when memory exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# Alerts - Storage Utilization
resource "azurerm_monitor_metric_alert" "storage_alert" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${var.name}-storage-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.default.id]
  description         = "Alert when storage exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
