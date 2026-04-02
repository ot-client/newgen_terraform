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