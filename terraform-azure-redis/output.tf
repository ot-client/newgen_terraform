output "redis_cache_details" {
  description = "Complete Redis cache details"
  value = {
    redis_id                = azurerm_redis_cache.redis.id
    redis_name              = azurerm_redis_cache.redis.name
    redis_hostname          = azurerm_redis_cache.redis.hostname
    redis_port              = azurerm_redis_cache.redis.port
    redis_ssl_port          = azurerm_redis_cache.redis.ssl_port
    redis_location          = azurerm_redis_cache.redis.location
    redis_resource_group    = azurerm_redis_cache.redis.resource_group_name
    redis_sku_name          = azurerm_redis_cache.redis.sku_name
    redis_family            = azurerm_redis_cache.redis.family
    redis_capacity          = azurerm_redis_cache.redis.capacity
    redis_version           = azurerm_redis_cache.redis.redis_version
    public_network_access   = azurerm_redis_cache.redis.public_network_access_enabled
  }
}

output "redis_connection_details" {
  description = "Redis connection information"
  value = {
    hostname                    = azurerm_redis_cache.redis.hostname
    port                        = azurerm_redis_cache.redis.port
    ssl_port                    = azurerm_redis_cache.redis.ssl_port
    primary_access_key          = azurerm_redis_cache.redis.primary_access_key
    secondary_access_key        = azurerm_redis_cache.redis.secondary_access_key
    primary_connection_string   = azurerm_redis_cache.redis.primary_connection_string
    secondary_connection_string = azurerm_redis_cache.redis.secondary_connection_string
  }
  sensitive = true
}

output "private_endpoint_details" {
  description = "Private endpoint configuration"
  value = {
    private_endpoint_id   = azurerm_private_endpoint.redis_pe.id
    private_endpoint_name = azurerm_private_endpoint.redis_pe.name
    private_ip_address    = azurerm_private_endpoint.redis_pe.private_service_connection[0].private_ip_address
    subnet_id            = azurerm_private_endpoint.redis_pe.subnet_id
  }
}

output "private_dns_zone_details" {
  description = "Private DNS zone information"
  value = {
    dns_zone_id   = azurerm_private_dns_zone.redis_dns.id
    dns_zone_name = azurerm_private_dns_zone.redis_dns.name
    dns_link_id   = azurerm_private_dns_zone_virtual_network_link.redis_dns_link.id
    dns_link_name = azurerm_private_dns_zone_virtual_network_link.redis_dns_link.name
  }
}

output "redis_configuration" {
  description = "Redis configuration summary"
  value = {
    name                    = azurerm_redis_cache.redis.name
    sku                     = azurerm_redis_cache.redis.sku_name
    capacity_gb             = azurerm_redis_cache.redis.capacity
    family                  = azurerm_redis_cache.redis.family
    version                 = azurerm_redis_cache.redis.redis_version
    tls_version             = azurerm_redis_cache.redis.minimum_tls_version
    access_keys_enabled     = true
    entra_auth_enabled      = false
    connectivity_method     = "Private Endpoint"
    public_access_enabled   = azurerm_redis_cache.redis.public_network_access_enabled
  }
}