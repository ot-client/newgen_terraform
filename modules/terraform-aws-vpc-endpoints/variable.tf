variable "region" {
  type = string

}
variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "endpoints" {
  description = "Map of VPC endpoints configuration"
  type = map(object({
    service_name       = string
    type               = string
    route_table_ids    = optional(list(string))
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))
    private_dns        = optional(bool)
    tags               = optional(map(string))
  }))
}

# variable "program" {
#   description = "Project/Program name"
#   type        = string
#   default     = ""
# }

# variable "vpc_endpoint_tags" {
#   description = "Tag for VPC endpoint specific resources"
#   type        = string
#   default     = ""
# }

variable "tags" {
  description = "Common tags applied to all endpoints"
  type        = map(string)
  default     = {}
}
