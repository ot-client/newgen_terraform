# CHANGED: Uncommented to create user-assigned identity for AKS (required for custom route table)
resource "azurerm_user_assigned_identity" "aks_identity" {
  count               = var.identity_type == "UserAssigned" ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.user_assigned_identity_name
}

# CHANGED: Uncommented - Grant Network Contributor role (user has Owner permission to do this via Terraform)
resource "azurerm_role_assignment" "route_table" {
  count                = var.identity_type == "UserAssigned" ? 1 : 0
  scope                = "/subscriptions/787ff5ea-eda4-47f2-b1a6-751605952ca7/resourceGroups/Buildpiper-test/providers/Microsoft.Network/routeTables/rt-aks-subnet7"
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity[0].principal_id
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.client_code}-AKS-${var.env}-s1-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.prefix

  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled           = var.private_cluster_enabled
  role_based_access_control_enabled = true
  # CHANGED: Removed automatic_upgrade_channel to disable automatic upgrades (client requirement - "none" is not valid)
  node_os_upgrade_channel           = var.node_os_upgrade_channel
  node_resource_group               = "${var.client_code}-AKS-RG-${var.env}"
  local_account_disabled            = false   


  # CHANGED: Using UserAssigned identity because subnet has custom route table attached
  identity {
    type = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.aks_identity[0].id] : null
  }

  # CHANGED: Added pod_cidr for kubenet network plugin
  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    outbound_type  = var.outbound_type
    pod_cidr       = var.network_plugin == "kubenet" ? "10.244.0.0/16" : null
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway_id != null ? [1] : []
    content {
      gateway_id = var.ingress_application_gateway_id
    }
  }

# CHANGED: Added zones to default_node_pool to match other pools
  default_node_pool {
    name                 = var.system_node_pool.name
    vm_size              = var.system_node_pool.vm_size
    node_count           = var.system_node_pool.enable_auto_scaling ? null : var.system_node_pool.node_count
    auto_scaling_enabled = var.system_node_pool.enable_auto_scaling
    min_count            = var.system_node_pool.enable_auto_scaling ? var.system_node_pool.min_count : null
    max_count            = var.system_node_pool.enable_auto_scaling ? var.system_node_pool.max_count : null
    zones                = var.system_node_pool.availability_zones
    vnet_subnet_id       = var.subnet_id
    max_pods             = var.system_node_pool.max_pods
    type                 = "VirtualMachineScaleSets"
  }

  tags = var.tags
}

# -------------------------------
# User Node Pool
# -------------------------------

# CHANGED: Added zones and node_labels to user node pool
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = var.user_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size    = var.user_node_pool.vm_size
  node_count = var.user_node_pool.enable_auto_scaling ? null : var.user_node_pool.node_count

  auto_scaling_enabled = var.user_node_pool.enable_auto_scaling
  min_count            = var.user_node_pool.enable_auto_scaling ? var.user_node_pool.min_count : null
  max_count            = var.user_node_pool.enable_auto_scaling ? var.user_node_pool.max_count : null
  zones                = var.user_node_pool.availability_zones
  vnet_subnet_id       = var.subnet_id
  max_pods             = var.user_node_pool.max_pods
  node_labels          = var.user_node_pool.labels
  mode                 = "User"
}

# -------------------------------
# Observability Node Pool
# -------------------------------

# CHANGED: Added zones to observability node pool
resource "azurerm_kubernetes_cluster_node_pool" "observability" {
  name                  = var.observability_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size              = var.observability_node_pool.vm_size
  node_count           = var.observability_node_pool.node_count
  auto_scaling_enabled = false
  zones                = var.observability_node_pool.availability_zones
  vnet_subnet_id       = var.subnet_id
  max_pods             = var.observability_node_pool.max_pods
  node_labels          = var.observability_node_pool.labels
  node_taints          = var.observability_node_pool.taints
  mode                 = "User"
}
