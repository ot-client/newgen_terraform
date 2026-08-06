resource "azurerm_storage_account" "storage_account" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = var.account_kind
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  access_tier                   = var.account_kind != "FileStorage" ? var.access_tier : null
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = var.min_tls_version
  is_hns_enabled                = var.is_hns_enabled

  network_rules {
    default_action             = var.network_rules_default_action
    bypass                     = var.network_rules_bypass
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }


  # File Share Soft Delete Retention
  dynamic "share_properties" {
    for_each = var.account_kind != "FileStorage" && var.share_retention_days > 0 ? [1] : []

    content {
      retention_policy {
        days = var.share_retention_days
      }
    }
  }


  # Blob Versioning
  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" ? [1] : []

    content {
      versioning_enabled = var.blob_versioning_enabled
    }
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



# Blob Diagnostic Logs
resource "azurerm_monitor_diagnostic_setting" "blob_diagnostics" {

  count = var.diagnostic_settings_enabled && var.account_kind != "FileStorage" ? 1 : 0

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




# Single Storage Management Policy
# Contains:
# 1. Diagnostic log retention
# 2. Container wise blob retention

resource "azurerm_storage_management_policy" "lifecycle_policy" {

  count = (
    var.account_kind != "FileStorage" &&
    (
      var.log_retention_enabled ||
      length(var.blob_lifecycle_rules) > 0
    )
  ) ? 1 : 0


  storage_account_id = azurerm_storage_account.storage_account.id



  # Diagnostic Log Retention

  dynamic "rule" {

    for_each = var.log_retention_enabled ? [1] : []

    content {

      name    = "blob-diagnostic-log-retention"
      enabled = true


      filters {

        prefix_match = [
          "insights-logs-storageread",
          "insights-logs-storagewrite",
          "insights-logs-storagedelete"
        ]


        blob_types = [
          "blockBlob"
        ]

      }


      actions {

        base_blob {

          delete_after_days_since_modification_greater_than = var.log_retention_days

        }

      }
    }
  }




  # Container Wise Blob Retention

  dynamic "rule" {

    for_each = var.blob_lifecycle_rules


    content {

      name = "retention-${rule.key}"

      enabled = true



      filters {

        prefix_match = [
          "${rule.key}/"
        ]


        blob_types = [
          "blockBlob"
        ]

      }



      actions {

        base_blob {

          delete_after_days_since_modification_greater_than = rule.value.retention_days

        }

      }

    }

  }

}




resource "azurerm_storage_container" "container" {

  for_each = var.account_kind != "FileStorage" ? var.containers : {}


  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type

}




resource "azurerm_storage_share" "file_share" {

  for_each = var.file_shares


  name               = each.key
  storage_account_id = azurerm_storage_account.storage_account.id
  quota              = each.value.quota_gb

  access_tier = var.account_kind != "FileStorage" ? each.value.access_tier : null

}




# Provisioned v2 File Share IOPS / Throughput

resource "azapi_update_resource" "file_share_provisioned_v2" {

  for_each = {
    for k, v in var.file_shares : k => v
    if v.billing_model == "provisioned_v2" &&
    (v.provisioned_iops != null || v.provisioned_bandwidth_mibps != null)
  }


  type = "Microsoft.Storage/storageAccounts/fileServices/shares@2024-01-01"


  resource_id = "${azurerm_storage_account.storage_account.id}/fileServices/default/shares/${each.key}"



  body = {

    properties = {

      shareQuota = each.value.quota_gb

      provisionedIops = each.value.provisioned_iops

      provisionedBandwidthMibps = each.value.provisioned_bandwidth_mibps

    }

  }


  depends_on = [
    azurerm_storage_share.file_share
  ]

}