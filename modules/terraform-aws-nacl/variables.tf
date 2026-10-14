variable "vpc_id" {
  type        = string
  description = "VPC in which the NACLs are created"
}

variable "nacls" {
  description = "Map of NACL name => subnets and ingress/egress rules"
  type = map(object({
    subnet_ids = list(string)
    ingress = optional(list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = optional(number, 0)
      to_port    = optional(number, 0)
    })), [])
    egress = optional(list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = optional(number, 0)
      to_port    = optional(number, 0)
    })), [])
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
