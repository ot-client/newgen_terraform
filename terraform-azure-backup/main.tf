resource "azurerm_recovery_services_vault" "vault" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vault_sku
  soft_delete_enabled = var.soft_delete_enabled
  storage_mode_type   = var.storage_mode_type
  
  # Enable cross-region restore (requires GeoRedundant storage)
  cross_region_restore_enabled = var.cross_region_restore_enabled && var.storage_mode_type == "GeoRedundant"
  
  tags = var.tags
}

# Backup Policy for VMs - Daily schedule with retention
resource "azurerm_backup_policy_vm" "vm_policy" {
  name                = var.vm_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone            = var.timezone

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }
}

# Protect VMs - map of vm_name => vm_id passed from wrapper tfvars
resource "azurerm_backup_protected_vm" "vm" {
  for_each            = var.vm_ids
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = each.value
  backup_policy_id    = azurerm_backup_policy_vm.vm_policy.id
}

# ========================================
# Azure Site Recovery Configuration
# ========================================

# Site Recovery Fabric (Source Region)
resource "azurerm_site_recovery_fabric" "primary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "${var.location}-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.location
}

# Site Recovery Fabric (Target Region)
resource "azurerm_site_recovery_fabric" "secondary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "${var.target_location}-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.target_location
}

# Site Recovery Replication Policy
resource "azurerm_site_recovery_replication_policy" "policy" {
  count                                                = var.enable_site_recovery ? 1 : 0
  name                                                 = var.replication_policy_name
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.vault.name
  recovery_point_retention_in_minutes                  = var.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = var.application_consistent_snapshot_frequency_in_minutes
}

# Site Recovery Protection Container (Source)
resource "azurerm_site_recovery_protection_container" "primary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "${var.location}-protection-container"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary[0].name
}

# Site Recovery Protection Container (Target)
resource "azurerm_site_recovery_protection_container" "secondary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "${var.target_location}-protection-container"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary[0].name
}

# Site Recovery Protection Container Mapping
resource "azurerm_site_recovery_protection_container_mapping" "container_mapping" {
  count                                     = var.enable_site_recovery ? 1 : 0
  name                                      = "${var.location}-to-${var.target_location}-mapping"
  resource_group_name                       = var.resource_group_name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary[0].name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary[0].name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary[0].id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy[0].id
}
