resource "azurerm_recovery_services_vault" "vault" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vault_sku
  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags
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
