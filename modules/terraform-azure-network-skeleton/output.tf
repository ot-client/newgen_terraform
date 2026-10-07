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
  value = {
    for k, a in local.route_table_associations : a.subnet => azurerm_route_table.rt[a.rt_key].id
  }
}

output "route_table_names" {
  description = "Map of subnet key => associated route table name"
  value = {
    for k, a in local.route_table_associations : a.subnet => azurerm_route_table.rt[a.rt_key].name
  }
}

output "route_tables" {
  description = "Map of route table key => id and name"
  value = {
    for k, v in azurerm_route_table.rt : k => { id = v.id, name = v.name }
  }
}
