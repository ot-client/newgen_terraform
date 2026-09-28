output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    for k, v in azurerm_subnet.subnets :
    k => v.id
  }
}

output "subnet_names" {
  description = "Map of subnet names"
  value = {
    for k, v in azurerm_subnet.subnets :
    k => v.name
  }
}

output "route_table_ids" {
  description = "Map of subnet key => associated route table ID"
  value = var.route_table != null ? {
    for k in var.route_table.subnets : k => azurerm_route_table.shared[0].id
    } : {
    for k, v in azurerm_route_table.rt : k => v.id
  }
}

output "route_table_names" {
  description = "Map of subnet key => associated route table name"
  value = var.route_table != null ? {
    for k in var.route_table.subnets : k => azurerm_route_table.shared[0].name
    } : {
    for k, v in azurerm_route_table.rt : k => v.name
  }
}
