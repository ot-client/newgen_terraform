output "private_endpoint_ids" {
  value = {
    for k, v in azurerm_private_endpoint.pe :
    k => v.id
  }
}
