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



# Route tables are fully driven by var.route_tables (one entry = one route table
# with its own routes and subnet associations). The default 0.0.0.0/0 -> firewall
# route is NOT defined here; it is added by the firewall VM module via route table name.
locals {
  route_table_routes = merge([
    for rt_key, rt in var.route_tables : {
      for r_key, r in rt.routes : "${rt_key}-${r_key}" => merge(r, {
        rt_key = rt_key
        name   = r_key
      })
    }
  ]...)

  route_table_associations = merge([
    for rt_key, rt in var.route_tables : {
      for s_key in rt.subnets : "${rt_key}-${s_key}" => {
        rt_key = rt_key
        subnet = s_key
      }
    }
  ]...)
}

resource "azurerm_route_table" "rt" {
  for_each = var.route_tables

  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled

  tags = var.tags
}

resource "azurerm_route" "routes" {
  for_each = local.route_table_routes

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt[each.value.rt_key].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "association" {
  for_each = local.route_table_associations

  subnet_id      = azurerm_subnet.subnets[each.value.subnet].id
  route_table_id = azurerm_route_table.rt[each.value.rt_key].id
}

# Migration from the old single shared route table (route_table variable).
# Assumes the existing table is now defined under the key "main" in route_tables.
moved {
  from = azurerm_route_table.shared[0]
  to   = azurerm_route_table.rt["main"]
}

moved {
  from = azurerm_subnet_route_table_association.shared["subnet3"]
  to   = azurerm_subnet_route_table_association.association["main-subnet3"]
}

moved {
  from = azurerm_subnet_route_table_association.shared["subnet4"]
  to   = azurerm_subnet_route_table_association.association["main-subnet4"]
}

moved {
  from = azurerm_subnet_route_table_association.shared["subnet6"]
  to   = azurerm_subnet_route_table_association.association["main-subnet6"]
}
