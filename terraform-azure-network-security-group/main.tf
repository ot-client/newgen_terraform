resource "azurerm_network_security_group" "nsg" {
  for_each = var.nsg_rules

  name                = each.key
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags = merge(var.tags, {
    "Name" = "${var.tags["Customer-Code"]}-${each.key}-${var.tags["Environment"]}-S1-1"
  })
}

# Create NSG rules per NSG
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = {
    for rule in flatten([
      for subnet_key, subnet in var.nsg_rules : [
        for rule_key, rule in subnet.rules : {
          rule_key                     = "${subnet_key}-${rule_key}"
          subnet_key                   = subnet_key
          name                         = rule.name
          priority                     = rule.priority
          direction                    = rule.direction
          access                       = rule.access
          protocol                     = rule.protocol
          source_port_ranges           = rule.source_port_range == "*" ? null : split(",", rule.source_port_range)
          source_port_range            = rule.source_port_range == "*" ? "*" : null
          destination_port_ranges      = rule.destination_port_range == "*" ? null : split(",", rule.destination_port_range)
          destination_port_range       = rule.destination_port_range == "*" ? "*" : null
          source_address_prefixes      = rule.source_address_prefix == "*" ? null : split(",", rule.source_address_prefix)
          source_address_prefix        = rule.source_address_prefix == "*" ? "*" : null
          destination_address_prefixes = rule.destination_address_prefix == "*" ? null : split(",", rule.destination_address_prefix)
          destination_address_prefix   = rule.destination_address_prefix == "*" ? "*" : null
        }
      ]
    ]) : rule.rule_key => rule
  }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_ranges           = each.value.source_port_ranges
  source_port_range            = each.value.source_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  destination_port_range       = each.value.destination_port_range
  source_address_prefixes      = each.value.source_address_prefixes
  source_address_prefix        = each.value.source_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg[each.value.subnet_key].name
}

# Associate NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  for_each = var.subnets

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
