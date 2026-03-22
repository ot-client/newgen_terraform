resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.subnet_id != null ? 1 : 0
  name                = var.private_endpoint_name != null ? var.private_endpoint_name : "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.acr_name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
  }

  tags = var.tags
}
