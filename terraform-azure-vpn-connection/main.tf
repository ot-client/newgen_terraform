resource "azurerm_local_network_gateway" "lng" {
  name                = var.local_network_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.local_gateway_address
  address_space       = var.local_address_space
  
  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "connection" {
  name                = var.connection_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type                            = "IPsec"
  virtual_network_gateway_id      = var.virtual_network_gateway_id
  local_network_gateway_id        = azurerm_local_network_gateway.lng.id
  shared_key                      = var.shared_key
  
  connection_mode                 = var.connection_mode
  connection_protocol            = var.connection_protocol
  dpd_timeout_seconds            = var.dpd_timeout_seconds

  ipsec_policy {
    dh_group         = var.dh_group
    ike_encryption   = var.ike_encryption
    ike_integrity    = var.ike_integrity
    ipsec_encryption = var.ipsec_encryption
    ipsec_integrity  = var.ipsec_integrity
    pfs_group        = var.pfs_group
    sa_datasize      = var.sa_datasize
    sa_lifetime      = var.sa_lifetime
  }

  tags = var.tags
}
