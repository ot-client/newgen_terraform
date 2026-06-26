locals {
  azure_service_tags = ["GatewayManager", "Internet", "VirtualNetwork", "AzureLoadBalancer", "AzureCloud", "AzureTrafficManager", "Storage", "Sql"]
}

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
          source_address_prefixes      = (rule.source_address_prefix == "*" || contains(local.azure_service_tags, rule.source_address_prefix)) ? null : split(",", rule.source_address_prefix)
          source_address_prefix        = (rule.source_address_prefix == "*" || contains(local.azure_service_tags, rule.source_address_prefix)) ? rule.source_address_prefix : null
          destination_address_prefixes = (rule.destination_address_prefix == "*" || contains(local.azure_service_tags, rule.destination_address_prefix)) ? null : split(",", rule.destination_address_prefix)
          destination_address_prefix   = (rule.destination_address_prefix == "*" || contains(local.azure_service_tags, rule.destination_address_prefix)) ? rule.destination_address_prefix : null
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

  depends_on = [azurerm_network_security_rule.nsg_rules]
}

# Data source for Network Watcher
data "azurerm_network_watcher" "nw" {
  count               = var.enable_flow_logs ? 1 : 0
  name                = coalesce(var.network_watcher_name, "NetworkWatcher_${var.resource_group_location}")
  resource_group_name = var.network_watcher_resource_group
}

# Data source for Log Analytics Workspace to get workspace_id (UUID)
data "azurerm_log_analytics_workspace" "law" {
  count               = var.enable_flow_logs && var.flow_log_workspace_id != null ? 1 : 0
  name                = element(split("/", var.flow_log_workspace_id), length(split("/", var.flow_log_workspace_id)) - 1)
  resource_group_name = element(split("/", var.flow_log_workspace_id), 4)
}

# VNet Flow Logs (replaces deprecated NSG Flow Logs)
# Note: VNet Flow Logs capture traffic at VNet level, providing same functionality as NSG Flow Logs
resource "azurerm_network_watcher_flow_log" "vnet_flow_log" {
  for_each = var.enable_flow_logs ? toset([var.vnet_id]) : toset([])

  name                 = "${var.vnet_name}-flow-log"
  network_watcher_name = data.azurerm_network_watcher.nw[0].name
  resource_group_name  = var.network_watcher_resource_group
  target_resource_id   = each.value
  storage_account_id   = var.flow_log_storage_account_id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = var.flow_log_retention_days
  }

  # Traffic Analytics (requires Log Analytics Workspace)
  dynamic "traffic_analytics" {
    for_each = var.flow_log_workspace_id != null ? [1] : []
    content {
      enabled               = true
      workspace_id          = data.azurerm_log_analytics_workspace.law[0].workspace_id
      workspace_region      = var.resource_group_location
      workspace_resource_id = var.flow_log_workspace_id
      interval_in_minutes   = var.flow_log_traffic_analytics_interval
    }
  }

  tags = var.tags

  depends_on = [azurerm_subnet_network_security_group_association.subnet_nsg_association]
}
