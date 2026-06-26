output "postgresql_server_details" {
  description = "Complete PostgreSQL Flexible Server details"
  value = {
    server_id                     = azurerm_postgresql_flexible_server.default.id
    server_name                   = azurerm_postgresql_flexible_server.default.name
    server_fqdn                   = azurerm_postgresql_flexible_server.default.fqdn
    server_location               = azurerm_postgresql_flexible_server.default.location
    server_resource_group         = azurerm_postgresql_flexible_server.default.resource_group_name
    server_version                = azurerm_postgresql_flexible_server.default.version
    server_sku_name               = azurerm_postgresql_flexible_server.default.sku_name
    server_storage_mb             = azurerm_postgresql_flexible_server.default.storage_mb
    server_backup_retention_days  = azurerm_postgresql_flexible_server.default.backup_retention_days
    server_zone                   = azurerm_postgresql_flexible_server.default.zone
    server_administrator_login    = azurerm_postgresql_flexible_server.default.administrator_login
    server_public_network_access  = azurerm_postgresql_flexible_server.default.public_network_access_enabled
    server_delegated_subnet_id    = azurerm_postgresql_flexible_server.default.delegated_subnet_id
    server_private_dns_zone_id    = azurerm_postgresql_flexible_server.default.private_dns_zone_id
  }
}

output "private_dns_zone_details" {
  description = "Private DNS Zone information"
  value = {
    dns_zone_id                   = azurerm_private_dns_zone.private_dns.id
    dns_zone_name                 = azurerm_private_dns_zone.private_dns.name
    dns_zone_resource_group       = azurerm_private_dns_zone.private_dns.resource_group_name
    dns_zone_number_of_record_sets = azurerm_private_dns_zone.private_dns.number_of_record_sets
    dns_zone_max_number_of_record_sets = azurerm_private_dns_zone.private_dns.max_number_of_record_sets
  }
}

output "private_dns_vnet_link_details" {
  description = "Private DNS Zone Virtual Network Link details"
  value = {
    vnet_link_id              = azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.id
    vnet_link_name            = azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.name
    vnet_link_virtual_network_id = azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.virtual_network_id
    vnet_link_resource_group  = azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.resource_group_name
  }
}

output "connection_details" {
  description = "PostgreSQL connection information"
  value = {
    server_fqdn     = azurerm_postgresql_flexible_server.default.fqdn
    server_port     = 5432
    database_name   = "postgres"
    admin_username  = azurerm_postgresql_flexible_server.default.administrator_login
    connection_string = "postgresql://${azurerm_postgresql_flexible_server.default.administrator_login}@${azurerm_postgresql_flexible_server.default.fqdn}:5432/postgres"
  }
  sensitive = true
}

output "server_configuration" {
  description = "Server configuration details"
  value = {
    server_name               = azurerm_postgresql_flexible_server.default.name
    server_version            = azurerm_postgresql_flexible_server.default.version
    server_sku                = azurerm_postgresql_flexible_server.default.sku_name
    storage_size_mb           = azurerm_postgresql_flexible_server.default.storage_mb
    backup_retention_days     = azurerm_postgresql_flexible_server.default.backup_retention_days
    availability_zone         = azurerm_postgresql_flexible_server.default.zone
    location                  = azurerm_postgresql_flexible_server.default.location
  }
}