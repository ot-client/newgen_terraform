

resource "azurerm_private_endpoint" "pe" {
  for_each = var.private_endpoints

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = each.value.name
    private_connection_resource_id = each.value.resource_id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_names
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = each.value.private_dns_zone_ids
  }

  tags = var.tags
}