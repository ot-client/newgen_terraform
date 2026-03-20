variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "tgw_route_cidr_block" {
  type        = string
  description = "CIDR block for route entries"
  default     = "10.0.0.0/8"
}

variable "vpc_attachments" {
  type = list(object({
    name                             = string
    vpc_id                           = string
    subnet_ids                       = list(string)
    route_table_id                   = optional(string)
    dns_support                      = string
    ipv6_support                     = string
    associate_with_tgw_route_table  = bool
    propagate_to_tgw_route_table    = bool
  }))
  description = "List of VPCs to attach to the TGW"
  default = [
    {
      name                            = "tgw-attachment-vpc-a"
      vpc_id                          = "vpc-0b2e7e2387bf08301"
      subnet_ids                      = ["subnet-034233dfae169f63f", "subnet-07d80237e1856b427"]
      route_table_id                  = "rtb-03557993cb1fba8f4"
      dns_support                     = "enable"
      ipv6_support                    = "disable"
      associate_with_tgw_route_table = true
      propagate_to_tgw_route_table   = true
    },
    {
      name                            = "tgw-attachment-vpcB"
      vpc_id                          = "vpc-0cda6bcbeb0cc309b"
      subnet_ids                      = ["subnet-0efbb6d6ffd83edf1", "subnet-068e80c046b559f24"]
      route_table_id                  = "rtb-0eabcfe9c5f495ed7"
      dns_support                     = "enable"
      ipv6_support                    = "disable"
      associate_with_tgw_route_table = false
      propagate_to_tgw_route_table   = true
    }
  ]
}

variable "region" {
  description = "AWS region (e.g., us-east-1, ap-south-1)."
  type        = string
#   default     = "us-east-1"
}