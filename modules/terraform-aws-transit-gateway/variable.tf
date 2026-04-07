variable "region" {
  type = string
}

variable "tgw_id" {
  description = "The ID of the existing Transit Gateway"
  type        = string
}

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
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
