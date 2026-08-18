variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
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