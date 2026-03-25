variable "name" {}
variable "resource_group_name" {}
variable "location" {}
variable "virtual_network_id" {}
variable "subnet_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "forwarding_rules" {
  type = map(object({
    domain_name = string
    target_dns_servers = list(object({
      ip   = string
      port = number
    }))
  }))
}
