variable "vpc_name" {
  description = "VPC name tag — used to look up VPC ID"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all security groups"
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = "Map of all security groups to create."
  type = map(object({
    name        = string
    description = optional(string, "Managed by Terraform")

    ingress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
      description = optional(string, "")
    })), [])

    egress_allow_all = optional(bool, true)

    egress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
      description = optional(string, "")
    })), [])
  }))
}
