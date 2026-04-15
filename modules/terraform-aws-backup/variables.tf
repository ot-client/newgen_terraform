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

variable "iam_role_policies" {
  description = "List of IAM policy ARNs to attach to the backup role."
  type        = list(string)
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
