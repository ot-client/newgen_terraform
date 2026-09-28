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

variable "exclude_subnets" {
  description = "List of subnet keys to exclude from route table association"
  type        = list(string)
  default     = []
}

variable "route_table" {
  description = <<-EOT
    Single shared route table attached only to the listed subnet keys.
    When null (default), one route table is created per subnet (legacy behaviour).
      name    = route table name
      subnets = subnet keys from var.subnets to associate (e.g. ["subnet3", "subnet4", "subnet6"])
  EOT
  type = object({
    name    = string
    subnets = list(string)
  })
  default = null

  validation {
    condition = var.route_table == null || alltrue([
      for k in try(var.route_table.subnets, []) : contains(keys(var.subnets), k) && k != "gateway"
    ])
    error_message = "route_table.subnets must be keys of var.subnets and must not include gateway."
  }
}
