resource "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = "StorageV2"
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  access_tier                   = var.access_tier
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    versioning_enabled = var.blob_versioning_enabled
  }

  share_properties {
    retention_policy {
      days = var.share_retention_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_share" "this" {
  for_each           = var.file_shares
  name               = each.key
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota_gb
  access_tier        = each.value.access_tier
}
