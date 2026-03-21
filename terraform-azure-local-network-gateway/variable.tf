variable "local_network_gateway_name" {
  description = "The name of the local network gateway"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the local network gateway"
  type        = string
}

variable "location" {
  description = "The location/region where the local network gateway is created"
  type        = string
}

variable "gateway_address" {
  description = "The gateway IP address to connect with (either this or gateway_fqdn must be specified)"
  type        = string
  default     = null
}

variable "gateway_fqdn" {
  description = "The gateway FQDN to connect with (either this or gateway_address must be specified)"
  type        = string
  default     = null
}

variable "address_space" {
  description = "The list of CIDR blocks for the address spaces exposed by the gateway"
  type        = list(string)
  default     = []
}

variable "bgp_settings" {
  description = "Local Network Gateway's BGP speaker settings block"
  type = object({
    asn                 = number
    bgp_peering_address = string
    peer_weight         = optional(number)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    platform = "Azure"
    owner    = "Opstree"
    env      = "testing"
  }
}
