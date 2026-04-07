output "resolver_id" {
  description = "Private DNS Resolver ID"
  value       = azurerm_private_dns_resolver.resolver.id
}

output "resolver_name" {
  value = azurerm_private_dns_resolver.resolver.name
}

output "outbound_endpoint_id" {
  value = azurerm_private_dns_resolver_outbound_endpoint.outbound.id
}

output "outbound_endpoint_name" {
  value = azurerm_private_dns_resolver_outbound_endpoint.outbound.name
}

output "ruleset_id" {
  value = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
}

output "ruleset_name" {
  value = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.name
}

output "forwarding_rules" {
  description = "All forwarding rules created"
  value = {
    for k, v in azurerm_private_dns_resolver_forwarding_rule.rules :
    k => {
      id          = v.id
      domain_name = v.domain_name
    }
  }
}

output "vnet_links" {
  description = "Virtual network links attached to DNS forwarding ruleset"
  value = {
    for k, v in azurerm_private_dns_resolver_virtual_network_link.vnet_links :
    k => {
      id                 = v.id
      virtual_network_id = v.virtual_network_id
      status             = "Successfully Linked"
    }
  }
}