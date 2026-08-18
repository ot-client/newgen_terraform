variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where private endpoints will be created"
  type        = string
}

variable "tags" {
  description = "Tags for private endpoints"
  type        = map(string)
  default     = {}
}

variable "private_endpoints" {
  description = "Map of private endpoints"

  type = map(object({
    name                 = string
    resource_id          = string
    subresource_names    = list(string)
    private_dns_zone_ids = list(string)
  }))
}