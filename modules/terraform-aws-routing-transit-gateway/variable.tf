variable "region" {
  description = "AWS region"
  type        = string
}

variable "tgw_id" {
  description = "ID of the existing Transit Gateway"
  type        = string
}

variable "tgw_route_cidr_block" {
  description = "Destination CIDR block for TGW route entries"
  type        = string
  default     = "10.0.0.0/8"
}

variable "route_table_ids" {
  description = "List of route table IDs to add TGW routes into"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "associate_with_tgw_route_table" {
  description = "Should we associate the route table with the transit gateway route table"
  type        = bool
  default     = false
}

variable "propagate_to_tgw_route_table" {
  description = "Should we propogate the route table with the transit gateway route table"
  type        = bool
  default     = false
}