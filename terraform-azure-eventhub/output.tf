output "namespace_id" {
  description = "The ID of the EventHub Namespace"
  value       = azurerm_eventhub_namespace.evh_ns.id
}

output "namespace_name" {
  description = "The name of the EventHub Namespace"
  value       = azurerm_eventhub_namespace.evh_ns.name
}

output "eventhub_id" {
  description = "The ID of the EventHub"
  value       = azurerm_eventhub.evh.id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = length(azurerm_private_endpoint.evh_pe) > 0 ? azurerm_private_endpoint.evh_pe[0].id : null
}
