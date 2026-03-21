output "vnet_details" {
  description = "Complete Virtual Network details"
  value = {
    vnet_name       = azurerm_virtual_network.vnet.name
    vnet_id         = azurerm_virtual_network.vnet.id
    location        = azurerm_virtual_network.vnet.location
    address_space   = azurerm_virtual_network.vnet.address_space
    resource_group  = azurerm_virtual_network.vnet.resource_group_name
  }
}

output "subnet_details" {
  description = "All subnet details"
  value = {
    for k, v in azurerm_subnet.subnets :
    k => {
      name             = v.name
      id               = v.id
      address_prefixes = v.address_prefixes
    }
  }
}

output "route_table_details" {
  description = "Route table information"
  value = {
    name                = azurerm_route_table.rt.name
    id                  = azurerm_route_table.rt.id
    resource_group_name = azurerm_route_table.rt.resource_group_name
    location            = azurerm_route_table.rt.location
  }
}

output "route_table_routes" {
  description = "Routes configured in route table"
  value = {
    name                   = azurerm_route.default_route.name
    address_prefix         = azurerm_route.default_route.address_prefix
    next_hop_type          = azurerm_route.default_route.next_hop_type
    next_hop_in_ip_address = azurerm_route.default_route.next_hop_in_ip_address
  }
}

output "subnet_route_table_associations" {
  description = "Which subnet is associated with route table"
  value = {
    for k, v in azurerm_subnet_route_table_association.association :
    k => {
      subnet_id      = v.subnet_id
      route_table_id = v.route_table_id
    }
  }
}