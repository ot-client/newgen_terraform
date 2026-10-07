variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the Virtual Network"
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    name       = string
    cidr       = string
    rt_name    = optional(string)
    delegation = optional(string)
  }))

  #  Validation (yeh tum abhi miss kar rahe the)
  validation {
    condition = alltrue([
      for s in var.subnets :
      can(cidrhost(s.cidr, 0))
    ])
    error_message = "Each subnet CIDR must be a valid CIDR block."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}

variable "route_tables" {
  description = <<-EOT
    Map of route tables to create. Key = logical name of the route table.
      name                          = route table name
      subnets                       = subnet keys from var.subnets to associate (not "gateway")
      bgp_route_propagation_enabled = default true
      routes                        = map of routes (key = route name)
        address_prefix         = destination CIDR
        next_hop_type          = VirtualNetworkGateway | VnetLocal | Internet | VirtualAppliance | None
        next_hop_in_ip_address = required only for VirtualAppliance
  EOT
  type = map(object({
    name                          = string
    subnets                       = optional(list(string), [])
    bgp_route_propagation_enabled = optional(bool, true)
    routes = optional(map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for rt in values(var.route_tables) : [
        for k in rt.subnets : contains(keys(var.subnets), k) && k != "gateway"
      ]
    ]))
    error_message = "route_tables[*].subnets must be keys of var.subnets and must not include gateway."
  }

  validation {
    condition     = length(flatten([for rt in values(var.route_tables) : rt.subnets])) == length(distinct(flatten([for rt in values(var.route_tables) : rt.subnets])))
    error_message = "A subnet can be associated with only one route table."
  }

  validation {
    condition = alltrue(flatten([
      for rt in values(var.route_tables) : [
        for r in values(rt.routes) :
        contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], r.next_hop_type)
        && (r.next_hop_type == "VirtualAppliance") == (r.next_hop_in_ip_address != null)
      ]
    ]))
    error_message = "Route next_hop_type must be a valid type, and next_hop_in_ip_address must be set only (and always) for VirtualAppliance."
  }
}
