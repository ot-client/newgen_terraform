resource "azurerm_eventhub_namespace" "evh_ns" {
  name                        = var.namespace_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku                         = var.sku
  capacity                    = var.capacity
  local_authentication_enabled = var.local_authentication_enabled
  public_network_access_enabled = false # Always false for Private connectivity

  tags = var.tags
}

resource "azurerm_eventhub" "evh" {
  name                = var.eventhub_name
  namespace_id        = azurerm_eventhub_namespace.evh_ns.id
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}

resource "azurerm_private_endpoint" "evh_pe" {
  count               = var.subnet_id != null ? 1 : 0
  name                = "${var.namespace_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.namespace_name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.evh_ns.id
    subresource_names              = ["namespace"]
  }

  tags = var.tags
}
