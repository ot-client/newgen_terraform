variable "region" {
  type = string
}

variable "resolver_rules" {
  description = "List of Resolver Rules to create and associate with VPCs"
  type = list(object({
    name                 = string
    domain_name          = string
    rule_type            = string        # FORWARD | SYSTEM | RECURSIVE
    resolver_endpoint_id = optional(string, null)
    target_ips = optional(list(object({
      ip   = string
      port = optional(number, 53)
    })), [])
    vpc_ids = list(string)              # VPCs to associate this rule with
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
