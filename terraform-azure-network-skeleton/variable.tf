variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "vnet_cidr" {}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
}

variable "route_table_name" {}

variable "firewall_ip" {}

variable "tags" {
  type = map(string)
}