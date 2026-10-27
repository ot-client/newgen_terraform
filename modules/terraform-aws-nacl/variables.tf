variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs indexed by position"
  type        = list(string)
}

variable "nacl_subnet_map" {
  type = map(list(number))
}

variable "nacl_rules" {
  type = any
}

variable "tags" {
  type    = map(string)
  default = {}
}
