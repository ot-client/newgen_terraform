variable "region" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for vault encryption. null = AWS managed default key"
  type        = string
  default     = null
}

variable "plan_name" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "create_iam_role" {
  description = "Whether to create IAM role or use existing one"
  type        = bool
  default     = false
}

variable "iam_role_arn" {
  description = "ARN of existing IAM role (required if create_iam_role = false)"
  type        = string
  default     = ""
}

variable "iam_role_policies" {
  description = "List of IAM policy ARNs to attach to the backup role."
  type        = list(string)
  default     = []
}

variable "backup_rules" {
  description = "List of backup rules. Each defines its own schedule, window, and retention."
  type = list(object({
    rule_name                 = string
    schedule                  = string
    start_window_minutes      = number
    completion_window_minutes = number
    retention_days            = number
  }))
}

variable "destination_vault_name" {
  description = "Name of the backup vault to create in destination region for cross-region copy"
  type        = string
  default     = ""
}

variable "destination_region" {
  description = "AWS region where the destination backup vault will be created"
  type        = string
  default     = ""
}

variable "copy_destination_vault_arn" {
  description = "ARN of the backup vault for cross-region copy (applied to all rules)"
  type        = string
  default     = ""
}

variable "backup_report_s3_bucket" {
  description = "S3 bucket name for AWS Backup audit report delivery"
  type        = string
  default     = ""
}

variable "backup_report_plan_name" {
  description = "Name for the backup report plan (letters, numbers, underscores only)"
  type        = string
  default     = ""
}

variable "selections" {
  description = "Map of backup selections. Supports tag-based and ARN-based selection."
  type = map(object({
    name           = string
    resource_arns  = list(string)
    tag_key        = string
    tag_value      = string
    resource_types = list(string)
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
