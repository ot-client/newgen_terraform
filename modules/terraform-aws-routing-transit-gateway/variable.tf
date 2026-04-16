variable "region" {
  description = "AWS region"
  type        = string
}

variable "tgw_routes" {
  description = "Map of TGW route configurations — each entry defines a TGW, destination CIDR and route tables"
  type = map(object({
    tgw_id                = string
    destination_cidr_block = string
    route_table_ids       = list(string)
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
