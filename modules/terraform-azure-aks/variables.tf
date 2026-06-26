##########################
# General Settings
##########################

variable "resource_group_name" {
  description = "(Required) The resource group name for AKS"
  type        = string
}

variable "location" {
  description = "(Required) The Azure region for AKS"
  type        = string
}

variable "cluster_name" {
  description = "(Required) The name of the AKS cluster"
  type        = string
}

variable "prefix" {
  description = "(Deprecated) Prefix for AKS resources - no longer used for dns_prefix"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
}

variable "sku_tier" {
  description = "AKS SKU tier"
  type        = string
}

variable "node_os_upgrade_channel" {
  description = "Node OS automatic upgrade channel"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Whether the cluster should be private"
  type        = bool
}

##########################
# Authentication
##########################

variable "identity_type" {
  description = "Identity type for the cluster: SystemAssigned/UserAssigned"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "Name of the user-assigned identity (if identity_type=UserAssigned)"
  type        = string
  default     = ""
}

variable "client_id" {
  description = "Client ID for service principal (optional)"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "Client secret for service principal (optional)"
  type        = string
  default     = ""
}

variable "client_name" {
  description = "AKS client name"
  type        = string
}

##########################
# Network
##########################

variable "network_plugin" {
  description = "Network plugin for AKS (azure/kubenet)"
  type        = string
}

variable "network_policy" {
  description = "Network policy (azure/calico)"
  type        = string
}

variable "service_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
}

variable "outbound_type" {
  description = "Cluster outbound type (loadBalancer/userDefinedRouting)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for all node pools"
  type        = string
}

variable "ingress_application_gateway_id" {
  description = "Application Gateway ID for ingress controller"
  type        = string
  default     = null
}

##########################
# Node Pools
##########################

variable "system_node_pool" {
  description = "Configuration for system node pool"
  type = object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    availability_zones  = list(string)
    max_pods            = number
  })
}

variable "user_node_pool" {
  description = "Configuration for user node pool"
  type = object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    availability_zones  = list(string)
    max_pods            = number
    labels              = map(string)
  })
}

variable "observability_node_pool" {
  description = "Configuration for observability node pool"
  type = object({
    name               = string
    vm_size            = string
    node_count         = number
    availability_zones = list(string)
    max_pods           = number
    labels             = map(string)
    taints             = list(string)
  })
}

##########################
# ACR
##########################

variable "client_code" {
  description = "Client code for naming"
  type        = string
}

variable "env" {
  description = "Environment code"
  type        = string
}

variable "acr_id" {
  description = "ACR resource ID for AcrPull role"
  type        = string
}

variable "create_role_assignments" {
  description = "Whether to create role assignments (requires elevated permissions)"
  type        = bool
  default     = true
}

variable "infrastructure_resource_group" {
  description = "Infrastructure resource group name (optional, will use default pattern if empty)"
  type        = string
  default     = ""
}

variable "route_table_resource_id" {
  description = "Full resource ID of the route table for Network Contributor role assignment"
  type        = string
  default     = ""
}

variable "pod_cidr" {
  description = "Pod CIDR for kubenet network plugin (only used when network_plugin=kubenet)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "default_node_pool_type" {
  description = "Type for default node pool (VirtualMachineScaleSets or AvailabilitySet)"
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "acr_role_definition_name" {
  description = "Role definition name for ACR access (e.g., AcrPull, AcrPush, etc.)"
  type        = string
  default     = "AcrPull"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster (if not provided, will use cluster name)"
  type        = string
  default     = ""
}