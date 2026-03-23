output "connection_id" {
  description = "The ID of the virtual network gateway connection."
  value       = azurerm_virtual_network_gateway_connection.connection.id
}

output "lng_id" {
  description = "The ID of the local network gateway."
  value       = azurerm_local_network_gateway.lng.id
}
