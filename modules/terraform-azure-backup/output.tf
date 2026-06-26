output "vault_id" {
  value = azurerm_recovery_services_vault.vault.id
}

output "vault_name" {
  value = azurerm_recovery_services_vault.vault.name
}

output "vm_policy_id" {
  value = azurerm_backup_policy_vm.vm_policy.id
}
