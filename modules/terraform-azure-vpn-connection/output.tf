output "connection_id" {
  description = "The ID of the virtual network gateway connection."
  value       = azurerm_virtual_network_gateway_connection.connection.id
}

output "lng_id" {
  description = "The ID of the local network gateway."
  value       = var.existing_lng_id != null ? var.existing_lng_id : azurerm_local_network_gateway.lng[0].id
}
