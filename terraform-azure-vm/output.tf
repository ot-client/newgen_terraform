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

output "firewall_routes" {
  description = "Firewall routes created by this VM"
  value = var.firewall_nic_id == "self" ? {
    for k, v in azurerm_route.firewall_route : k => {
      route_table_name = v.route_table_name
      address_prefix   = v.address_prefix
      next_hop_type    = v.next_hop_type
      route_id         = v.id
    }
  } : {}
}
