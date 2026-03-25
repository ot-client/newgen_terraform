variable "region" {
  type = string
}

variable "tgw_id" {
  description = "The ID of the existing Transit Gateway"
  type        = string
}

# variable "tgw_route_cidr_block" {
#   type    = string
# }

variable "description" {
    type = string
}

variable "security_group_referencing_support" {
    type = string
}

variable "attachment_name" {
  type = list(object({
    name                          = string
    subnet_ids                    = list(string)
    vpc_id                        = string
    dns_support                   = string
    ipv6_support                  = string
    # associate_with_tgw_route_table = bool
    # propagate_to_tgw_route_table  = bool
  }))
}

variable "dns_support" {
  type = string
}

variable "ipv6_support" {
  type = string
}

# variable "associate_with_tgw_route_table" {
#   type = bool
#   default = false
# }

# variable "propagate_to_tgw_route_table" {
#   type = bool
#   default = false
# }