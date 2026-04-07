variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "rules" {
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    source_sg_id = optional(string)
    description = optional(string)
  }))
}

variable "eni_ids" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}