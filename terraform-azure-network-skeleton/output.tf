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
  description = "Map of route table IDs per subnet"
  value = {
    for k, v in azurerm_route_table.rt :
    k => v.id
  }
}

output "route_table_names" {
  description = "Map of route table names per subnet"
  value = {
    for k, v in azurerm_route_table.rt :
    k => v.name
  }
}