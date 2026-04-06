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

variable "rule_name" {
  type    = string
  default = "DailyBackup"
}

variable "iam_role_name" {
  type = string
}

# Schedule
variable "schedule_hour" {
  description = "Hour (UTC) to start backup, e.g. 5 for 05:00"
  type        = number
  default     = 5
}

variable "schedule_minute" {
  description = "Minute to start backup, e.g. 0 for :00"
  type        = number
  default     = 0
}

variable "schedule_timezone" {
  description = "Timezone for the backup schedule"
  type        = string
  default     = "Etc/UTC"
}

# Backup window
variable "start_window_minutes" {
  description = "Minutes within which backup must start (1 hour = 60)"
  type        = number
  default     = 60
}

variable "completion_window_minutes" {
  description = "Minutes within which backup must complete (5 hours = 300)"
  type        = number
  default     = 300
}

# Retention
variable "retention_days" {
  description = "Number of days to retain backups (1 week = 7)"
  type        = number
  default     = 7
}

variable "iam_role_policies" {
  description = "List of IAM policy ARNs to attach to the backup role."
  type        = list(string)
}

variable "selections" {
  description = "Map of backup selections. Add any service (EC2, Aurora, EFS, etc.) here via tfvars."
  type = map(object({
    name          = string
    resource_arns = list(string)
    tag_key       = string
    tag_value     = string
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
