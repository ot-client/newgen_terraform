variable "region" {
  type = string
}

variable "roles" {
  description = "Map of IAM roles with managed and custom policies"
  type = map(object({
    managed_policy_arns = list(string)
    custom_policy_names = list(string)
    custom_trust_policy = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for role, data in var.roles : alltrue([
        for arn in data.managed_policy_arns :
        !can(regex("arn:aws:iam::aws:policy/aws-service-role/", arn))
      ])
    ])
    error_message = "managed_policy_arns in 'roles' contains an AWS reserved service-linked policy (aws-service-role/). These cannot be attached to custom roles."
  }
}

variable "custom_policies" {
  description = "Custom IAM policies to create"
  type = map(object({
    description = string
    policy_json = string
  }))
  default = {}
}

variable "assume_role_service" {
  description = "Service principal for assume role policy"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "custom_trust_policy_roles" {
  description = "Map of IAM roles with a fully custom trust policy JSON"
  type = map(object({
    custom_trust_policy = string
    managed_policy_arns = list(string)
    custom_policy_names = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for role, data in var.custom_trust_policy_roles : alltrue([
        for arn in data.managed_policy_arns :
        !can(regex("arn:aws:iam::aws:policy/aws-service-role/", arn))
      ])
    ])
    error_message = "managed_policy_arns in 'custom_trust_policy_roles' contains an AWS reserved service-linked policy (aws-service-role/). These cannot be attached to custom roles."
  }
}
