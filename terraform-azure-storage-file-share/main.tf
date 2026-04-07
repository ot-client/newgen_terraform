resource "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = var.account_kind
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  access_tier                   = var.access_tier
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = var.min_tls_version

  network_rules {
    default_action = var.network_rules_default_action
    bypass         = var.network_rules_bypass
  }

  share_properties {
    retention_policy {
      days = var.share_retention_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_share" "this" {
  for_each                      = var.file_shares
  name                          = each.key
  storage_account_id            = azurerm_storage_account.this.id
  quota                         = each.value.quota_gb
  access_tier                   = each.value.access_tier
  provisioned_iops              = each.value.provisioned_iops
  provisioned_bandwidth_mibps   = each.value.provisioned_bandwidth_mibps
}
