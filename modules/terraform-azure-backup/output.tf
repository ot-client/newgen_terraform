output "vault_id" {
  value = azurerm_recovery_services_vault.vault.id
}

output "vault_name" {
  value = azurerm_recovery_services_vault.vault.name
}

output "vm_policy_id" {
  value = local.selected_backup_policy_id
}

output "backup_policy_id" {
  value = local.selected_backup_policy_id
}

output "backup_policy_name" {
  value = local.selected_backup_policy_name
}
