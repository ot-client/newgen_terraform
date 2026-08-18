output "private_endpoint_ids" {
  description = "Private endpoint IDs keyed by service"
  value = {
    for k, v in azurerm_private_endpoint.pe :
    k => v.id
  }
}

output "private_endpoint_names" {
  description = "Private endpoint names keyed by service"
  value = {
    for k, v in azurerm_private_endpoint.pe :
    k => v.name
  }
}