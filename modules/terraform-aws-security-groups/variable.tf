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
      from_port      = number
      to_port        = number
      protocol       = string
      cidr_blocks    = optional(list(string), [])
      description    = optional(string, "")
      source_sg_key  = optional(string, null) # same-stack SG key e.g. "rds_sg"
      source_sg_id   = optional(string, null) # external hardcoded SG ID e.g. "sg-0abc123"
      prefix_list_id = optional(string, null) # AWS prefix list ID e.g. "pl-63a5400a"
    })), [])

    egress_allow_all = optional(bool, true)

    egress_rules = optional(list(object({
      from_port      = number
      to_port        = number
      protocol       = string
      cidr_blocks    = optional(list(string), [])
      description    = optional(string, "")
      source_sg_key  = optional(string, null) # same-stack SG key e.g. "rds_sg"
      source_sg_id   = optional(string, null) # external hardcoded SG ID e.g. "sg-0abc123"
      prefix_list_id = optional(string, null) # AWS prefix list ID e.g. "pl-63a5400a"
    })), [])
  }))
}
