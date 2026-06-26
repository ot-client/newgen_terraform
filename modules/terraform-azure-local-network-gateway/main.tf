resource "azurerm_local_network_gateway" "local_network_gateway" {
  name                = var.local_network_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_fqdn == null ? var.gateway_address : null
  gateway_fqdn        = var.gateway_address == null ? var.gateway_fqdn : null
  address_space       = var.address_space

  dynamic "bgp_settings" {
    for_each = var.bgp_settings != null ? [var.bgp_settings] : []
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = bgp_settings.value.peer_weight
    }
  }

  tags = var.tags
}
