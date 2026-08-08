resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                        = georeplications.value.location
      zone_redundancy_enabled         = georeplications.value.zone_redundancy_enabled
      global_endpoint_routing_enabled = georeplications.value.global_endpoint_routing_enabled
    }
  }
}
