resource "azurerm_storage_account" "storage_account" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  access_tier                   = var.access_tier
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = var.min_tls_version
  is_hns_enabled                = var.is_hns_enabled

  network_rules {
    default_action             = var.network_rules_default_action
    bypass                     = var.network_rules_bypass
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  blob_properties {
    versioning_enabled = var.blob_versioning_enabled
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  count                      = var.diagnostic_settings_enabled ? 1 : 0
  name                       = "${var.storage_account_name}-diagnostics"
  target_resource_id         = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.archive_storage_account_id

  enabled_metric {
    category = "Transaction"
  }

  enabled_metric {
    category = "Capacity"
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob_diagnostics" {
  count                      = var.diagnostic_settings_enabled ? 1 : 0
  name                       = "${var.storage_account_name}-blob-diagnostics"
  target_resource_id         = "${azurerm_storage_account.storage_account.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.archive_storage_account_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_storage_management_policy" "log_retention" {
  count              = var.log_retention_enabled ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = "blob-diagnostic-log-retention"
    enabled = true
    filters {
      prefix_match = ["insights-logs-storageread", "insights-logs-storagewrite", "insights-logs-storagedelete"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_retention_days
      }
    }
  }
}

resource "azurerm_storage_container" "container" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type
}
