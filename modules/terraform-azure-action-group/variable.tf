variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "action_groups" {
  description = "Map of action groups to create. Key is a logical identifier."
  type = map(object({
    name       = string
    short_name = string
    email_receivers = list(object({
      name          = string
      email_address = string
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags applied to all action groups"
  type        = map(string)
  default     = {}
}
