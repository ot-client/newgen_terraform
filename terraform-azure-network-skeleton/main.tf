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

dynamic "delegation" {
  for_each = lookup(each.value, "delegation", null) != null ? [1] : []

  content {
    name = "${each.value.name}-delegation"

    service_delegation {
      name = (
        each.value.delegation == "postgres"
        ? "Microsoft.DBforPostgreSQL/flexibleServers"
        : each.value.delegation == "dnsResolvers"
        ? "Microsoft.Network/dnsResolvers"
        : each.value.delegation
      )

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}
}



resource "azurerm_route_table" "rt" {
  for_each = {
    for k, v in var.subnets :
    k => v if k != "gateway" && !contains(var.exclude_subnets, k)
  }

  name                = coalesce(each.value.rt_name, "${each.value.name}-rt")
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "association" {
  for_each = azurerm_route_table.rt

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = each.value.id
}