variable "repo_details" {
  description = "Map of repository names to their configuration. Supports both private and public repos."
  type = map(object({
    repository_type          = string           # "private" or "public"
    max_untagged_image_count = optional(number) # private only
    max_tagged_image_count   = optional(number) # private only
    catalog_data = optional(object({            # public only
      about_text        = optional(string)
      architectures     = optional(list(string))
      description       = optional(string)
      logo_image_blob   = optional(string)
      operating_systems = optional(list(string))
      usage_text        = optional(string)
    }))
  }))
}

##################################
# IAM Access Control
##################################
variable "only_pull_accounts" {
  description = "List of AWS account IDs allowed to pull images only."
  type        = list(string)
  default     = []
}

variable "push_and_pull_accounts" {
  description = "List of AWS account IDs allowed to push and pull images."
  type        = list(string)
  default     = []
}

##################################
# Repository Settings
##################################
variable "image_tag_mutability" {
  description = "Tag mutability for private repositories. Must be MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "Whether to force-delete private repositories even if they contain images."
  type        = bool
  default     = false
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning on push for private repositories."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for private repositories. Must be AES256 or KMS."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for private repo encryption. Only used when encryption_type = KMS."
  type        = string
  default     = null
}

variable "tag_prefix_list" {
  description = "Tag prefixes used in the lifecycle policy to identify tagged images."
  type        = list(string)
  default     = ["latest", "stable"]
}

##################################
# Tags
##################################
variable "tags" {
  description = "Additional tags to merge onto all resources. Pass env, app, owner here."
  type        = map(string)
  default     = {}
}
