variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type = string
}

variable "route_table_names" {
  type = list(string)
}

variable "route_table_subnet_map" {
  type = map(list(number))
}

variable "subnet_ids" {
  description = "List of subnet IDs indexed by position"
  type        = list(string)
}

variable "igw_rt" {
  type = string
}

variable "destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_routes" {
  description = "Map of ENI routes — pass instance_id, ENI is fetched automatically"
  type = map(object({
    route_table_name       = string
    destination_cidr_block = string
    instance_id            = string
  }))
  default = {}
}

variable "nat_routes" {
  description = "Map of NAT gateway routes"
  type = map(object({
    route_table_name       = string
    destination_cidr_block = string
    nat_gateway_id         = string
  }))
  default = {}
}

variable "tgw_routes" {
  description = "Map of Transit Gateway routes"
  type = map(object({
    route_table_name       = string
    destination_cidr_block = string
    transit_gateway_id     = string
  }))
  default = {}
}

variable "peering_routes" {
  description = "Map of VPC Peering routes"
  type = map(object({
    route_table_name          = string
    destination_cidr_block    = string
    vpc_peering_connection_id = string
  }))
  default = {}
}

variable "propagating_vgws" {
  description = "Map of VGW route propagations — enables VPN gateway to propagate routes into route tables"
  type = map(object({
    route_table_name = string
    vpn_gateway_id   = string
  }))
  default = {}
}
