resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]

  tags = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.cidr]
  
  # Add delegation for PostgreSQL Flexible Server if subnet is subnet5
  dynamic "delegation" {
    for_each = each.key == "subnet5" ? [1] : []
    content {
      name = "postgresql-delegation"
      service_delegation {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }
}

resource "azurerm_route_table" "rt" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_route" "default_route" {
  name                   = "default-fw-route"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

resource "azurerm_subnet_route_table_association" "association" {
#   for_each = azurerm_subnet.subnets
    for_each = {
    for k, v in azurerm_subnet.subnets : k => v if k != "gateway"
  }
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.rt.id
}