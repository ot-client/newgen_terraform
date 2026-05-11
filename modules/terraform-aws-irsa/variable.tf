variable "create_oidc_provider" {
  description = "Whether to create a new OIDC provider. Set false to use an existing one via existing_oidc_provider_arn"
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "ARN of an existing OIDC provider to use instead of creating a new one"
  type        = string
  default     = null
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from EKS cluster (e.g. https://oidc.eks.us-east-1.amazonaws.com/id/XXXX)"
  type        = string
}

variable "oidc_provider_name" {
  description = "Name tag for the OIDC provider"
  type        = string
}

variable "oidc_thumbprint_list" {
  description = "List of server certificate thumbprints for the OIDC provider"
  type        = list(string)
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

variable "oidc_client_id_list" {
  description = "List of client IDs for the OIDC provider"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "custom_trust_policy" {
  description = "Custom trust policy JSON string. When provided, overrides the auto-generated OIDC trust policy."
  type        = string
  default     = null
}

variable "irsa_roles" {
  description = "Map of IRSA roles to create with web identity trust policy"
  type = map(object({
    service_account     = string
    managed_policy_arns = list(string)
    custom_policy_names = list(string)
  }))
  default = {}
}

variable "custom_policies" {
  description = "Custom IAM policies to create and attach to IRSA roles"
  type = map(object({
    description = string
    policy_json = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
