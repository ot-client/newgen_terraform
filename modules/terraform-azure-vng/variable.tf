variable "virtual_network_gateway_name" {
  description = "The name of the Virtual Network Gateway."
  type        = string
}

variable "location" {
  description = "The Azure region where the Virtual Network Gateway should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku" {
  description = "Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4, VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ and VpnGw5AZ."
  type        = string
}

variable "type" {
  description = "The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute."
  type        = string
  default     = "Vpn"
}

variable "vpn_type" {
  description = "The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased."
  type        = string
  default     = "RouteBased"
}

variable "generation" {
  description = "The Generation of the Virtual Network Gateway. Possible values include Generation1, Generation2 or None."
  type        = string
  default     = "Generation1"
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist."
  type        = string
  default     = null
}

variable "active_active" {
  description = "If true, an active-active Virtual Network Gateway will be created."
  type        = bool
  default     = false
}

variable "bgp_enabled" {
  description = "If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway."
  type        = bool
  default     = false
}

variable "default_local_network_gateway_id" {
  description = "The ID of the local network gateway through which outbound Internet traffic from the virtual network should be routed."
  type        = string
  default     = null
}

variable "private_ip_address_enabled" {
  description = "Should a private IP be enabled on this gateway for telemetry?"
  type        = bool
  default     = null
}

variable "bgp_route_translation_for_nat_enabled" {
  description = "Is BGP Route Translation for NAT enabled?"
  type        = bool
  default     = null
}

variable "dns_forwarding_enabled" {
  description = "Is DNS forwarding enabled?"
  type        = bool
  default     = null
}

variable "ip_sec_replay_protection_enabled" {
  description = "Is IP Sec Replay Protection enabled?"
  type        = bool
  default     = null
}

variable "remote_vnet_traffic_enabled" {
  description = "Is remote VNet traffic enabled?"
  type        = bool
  default     = null
}

variable "virtual_wan_traffic_enabled" {
  description = "Is virtual WAN traffic enabled?"
  type        = bool
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "ip_configuration" {
  description = "List of IP configurations for the Virtual Network Gateway."
  type = list(object({
    name                          = string
    public_ip_address_id          = string
    subnet_id                     = string
    private_ip_address_allocation = string
  }))
}

variable "policy_group" {
  description = "List of policy groups for the Virtual Network Gateway."
  type = list(object({
    name       = string
    is_default = bool
    priority   = number
    policy_member = list(object({
      name  = string
      type  = string
      value = string
    }))
  }))
  default = []
}

variable "vpn_client_configuration" {
  description = "VPN client configuration for the Virtual Network Gateway."
  type = object({
    address_space         = list(string)
    aad_tenant            = string
    aad_audience          = string
    aad_issuer            = string
    vpn_client_protocols  = list(string)
    vpn_auth_types        = list(string)
    radius_server_address = string
    radius_server_secret  = string
    ipsec_policy = list(object({
      dh_group                  = string
      ike_encryption            = string
      ike_integrity             = string
      ipsec_encryption          = string
      ipsec_integrity           = string
      pfs_group                 = string
      sa_data_size_in_kilobytes = number
      sa_lifetime_in_seconds    = number
    }))
    root_certificate = list(object({
      name             = string
      public_cert_data = string
    }))
    revoked_certificate = list(object({
      name       = string
      thumbprint = string
    }))
    radius_server = list(object({
      address = string
      secret  = string
      score   = number
    }))
    virtual_network_gateway_client_connection = list(object({
      name               = string
      policy_group_names = list(string)
      address_prefixes   = list(string)
    }))
  })
  default = null
}

variable "bgp_settings" {
  description = "BGP settings for the Virtual Network Gateway."
  type = object({
    asn         = number
    peer_weight = number
    peering_addresses = list(object({
      ip_configuration_name = string
      apipa_addresses       = list(string)
    }))
  })
  default = null
}

variable "custom_route" {
  description = "Custom route configuration for the Virtual Network Gateway."
  type = object({
    address_prefixes = list(string)
  })
  default = null
}
