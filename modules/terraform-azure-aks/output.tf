# AKS Cluster Outputs
output "aks_id" {
  description = "AKS resource ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_resource_group" {
  description = "Name of the resource group containing AKS nodes"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_kubernetes_version" {
  description = "Kubernetes version of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "aks_location" {
  description = "Location of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.location
}

# Identity Outputs
output "aks_identity_principal_id" {
  description = "Principal ID of the AKS cluster identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "aks_identity_tenant_id" {
  description = "Tenant ID of the AKS cluster identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
}

output "aks_kubelet_identity" {
  description = "Kubelet identity used by AKS agents"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned identity for AKS"
  value       = var.identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].id : null
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned identity"
  value       = var.identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].principal_id : null
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned identity"
  value       = var.identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].client_id : null
}

# Network Outputs
output "aks_network_profile" {
  description = "Network profile of the AKS cluster"
  value = {
    network_plugin    = azurerm_kubernetes_cluster.aks.network_profile[0].network_plugin
    network_policy    = azurerm_kubernetes_cluster.aks.network_profile[0].network_policy
    service_cidr      = azurerm_kubernetes_cluster.aks.network_profile[0].service_cidr
    dns_service_ip    = azurerm_kubernetes_cluster.aks.network_profile[0].dns_service_ip
    outbound_type     = azurerm_kubernetes_cluster.aks.network_profile[0].outbound_type
    load_balancer_sku = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_sku
  }
}

# Node Pool Outputs
output "system_node_pool_id" {
  description = "ID of the system node pool"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

output "user_node_pool_id" {
  description = "ID of the user node pool"
  value       = length(azurerm_kubernetes_cluster_node_pool.userpool) > 0 ? azurerm_kubernetes_cluster_node_pool.userpool[0].id : null
}

output "observability_node_pool_id" {
  description = "ID of the observability node pool"
  value       = length(azurerm_kubernetes_cluster_node_pool.observability) > 0 ? azurerm_kubernetes_cluster_node_pool.observability[0].id : null
}

# Kubeconfig Output
output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw admin kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

# Additional Cluster Information
output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "aks_portal_fqdn" {
  description = "Portal FQDN for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.portal_fqdn
}

output "aks_private_fqdn" {
  description = "Private FQDN for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}