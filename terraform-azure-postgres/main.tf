resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = var.private_dns_zone_virtual_network_link_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
}


resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "${var.name}-server"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.posgressversion
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.private_dns.id
  administrator_login    = var.db_username
  administrator_password = var.db_password
  public_network_access_enabled = var.public_network_access_enabled
  zone =  var.postgres_zones
  lifecycle {
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }
  tags = merge(
  {
    "Name" = "${var.name}-server"
  },
  var.tags)          
  storage_mb             = var.storage_mb 
  sku_name               = var.sku_name 
  backup_retention_days  = var.backup_retention_days
}
