variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "subnets" {
  type = map(string) # map of subnet name => subnet id
}

variable "nsg_rules" {
  type = any
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    environment = "non-prod"
  }
}
