variable "region" {
  type = string
}

variable "roles" {
  description = "Map of IAM roles with managed and custom policies"
  type = map(object({
    managed_policy_arns = list(string)
    custom_policy_names = list(string)
  }))
}

variable "custom_policies" {
  description = "Custom IAM policies to create"
  type = map(object({
    description = string
    policy_json = string
  }))
}

variable "assume_role_service" {
  description = "Service principal for assume role policy"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
