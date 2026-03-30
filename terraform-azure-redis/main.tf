resource "azurerm_redis_cache" "redis" {
  name                          = var.redis_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = "C"
  sku_name                      = var.sku_name
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags
}

# Private endpoint managed separately in private-endpoint module
# resource "azurerm_private_dns_zone" "redis_dns" {
#   name                = var.private_dns_zone_name
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_link" {
#   name                  = var.private_dns_zone_virtual_network_link_name
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.redis_dns.name
#   virtual_network_id    = var.virtual_network_id
#   registration_enabled  = false
#   tags                  = var.tags
# }

# resource "azurerm_private_endpoint" "redis_pe" {
#   count               = var.enable_private_endpoint ? 1 : 0
#   name                = "${var.redis_name}-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id
#   private_service_connection {
#     name                           = "${var.redis_name}-psc"
#     private_connection_resource_id = azurerm_redis_cache.redis.id
#     subresource_names              = ["redisCache"]
#     is_manual_connection           = false
#   }
#   private_dns_zone_group {
#     name                 = "redis-dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.redis_dns.id]
#   }
#   tags = var.tags
# }