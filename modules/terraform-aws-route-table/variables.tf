variable "vpc_id" {
  type        = string
  description = "VPC in which the route tables are created"
}

variable "route_tables" {
  description = "Map of route table name => subnets to associate and routes to add"
  type = map(object({
    subnet_ids = list(string)
    routes = optional(list(object({
      cidr_block                = string
      gateway_id                = optional(string)
      nat_gateway_id            = optional(string)
      transit_gateway_id        = optional(string)
      vpc_endpoint_id           = optional(string)
      vpc_peering_connection_id = optional(string)
    })), [])
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
