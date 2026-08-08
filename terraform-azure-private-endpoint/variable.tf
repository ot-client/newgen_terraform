variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "tags" {}

variable "private_endpoints" {
  description = "Map of private endpoints"
  type = map(object({
    name                    = string
    resource_id             = string
    subresource_names       = list(string)
    private_dns_zone_ids    = list(string)
  }))
}
