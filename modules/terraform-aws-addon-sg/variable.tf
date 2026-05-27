variable "security_groups" {
  description = "Map of security groups configuration"
  type        = any
}

variable "tags" {
  type    = map(string)
  default = {}
}