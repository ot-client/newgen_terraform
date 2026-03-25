output "namespace_id" {
  value = azurerm_eventhub_namespace.evh_ns.id
}
output "namespace_name" {
  value = azurerm_eventhub_namespace.evh_ns.name
}
output "eventhub_id" {
  value = azurerm_eventhub.evh.id
}
