# variable "vnet_name" {}
# variable "location" {}
# variable "resource_group_name" {}
# variable "vnet_cidr" {}

# variable "subnets" {
#   type = map(object({
#     name    = string
#     cidr    = string
#     rt_name = optional(string)
#     delegation = optional(string)

#   }))
# }

# # variable "route_table_name" {}

# variable "firewall_ip" {}

# variable "tags" {
#   type = map(string)
# }

# variable "exclude_subnets" {
#   description = "List of subnet keys to exclude from route table association"
#   type        = list(string)
#   default     = []
# }

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

  # 🔥 Validation (yeh tum abhi miss kar rahe the)
  validation {
    condition = alltrue([
      for s in var.subnets :
      can(cidrhost(s.cidr, 0))
    ])
    error_message = "Each subnet CIDR must be a valid CIDR block."
  }
}

variable "firewall_ip" {
  type        = string
  description = "Firewall private IP for default route"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.firewall_ip))
    error_message = "Firewall IP must be a valid IPv4 address."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}

variable "exclude_subnets" {
  description = "List of subnet keys to exclude from route table association"
  type        = list(string)
  default     = []
}