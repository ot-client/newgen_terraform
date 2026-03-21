output "vm_id" {
  description = "The ID of the virtual machine"
  value       = one(concat(azurerm_linux_virtual_machine.vm.*.id, azurerm_windows_virtual_machine.vm.*.id))
}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.nic.id
}

output "private_ip" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "public_ip_id" {
  description = "The ID of the public IP"
  value       = var.public_ip_id
}
