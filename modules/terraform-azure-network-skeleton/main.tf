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



# Legacy mode (route_table = null): one route table per subnet,
# except gateway and exclude_subnets.
resource "azurerm_route_table" "rt" {
  for_each = var.route_table == null ? {
    for k, v in var.subnets :
    k => v if k != "gateway" && !contains(var.exclude_subnets, k)
  } : {}

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

# Shared mode (route_table set): a single route table attached only to
# the listed subnet keys. Routes (e.g. 0.0.0.0/0 -> firewall) are added
# by the firewall VM module via route table name.
resource "azurerm_route_table" "shared" {
  count = var.route_table != null ? 1 : 0

  name                = var.route_table.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "shared" {
  for_each = var.route_table != null ? toset(var.route_table.subnets) : toset([])

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.shared[0].id
}
