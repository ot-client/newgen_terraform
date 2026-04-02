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

variable "ec2_assignment_name" {
  type    = string
  default = "Backup_1"
}

variable "aurora_assignment_name" {
  type    = string
  default = "Backup_2"
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

# EC2 selection tags
variable "ec2_tag_key" {
  description = "Tag key to filter EC2 instances for backup"
  type        = string
  default     = "Backup"
}

variable "ec2_tag_value" {
  description = "Tag value to filter EC2 instances for backup"
  type        = string
  default     = "True"
}

variable "ec2_resource_arns" {
  description = "EC2 resource ARNs - all instances by default"
  type        = list(string)
  default     = ["arn:aws:ec2:*:*:instance/*"]
}

# Aurora selection tags
variable "aurora_tag_key" {
  description = "Tag key to filter Aurora clusters for backup"
  type        = string
  default     = "Backup"
}

variable "aurora_tag_value" {
  description = "Tag value to filter Aurora clusters for backup"
  type        = string
  default     = "True"
}

variable "aurora_resource_arns" {
  description = "Aurora resource ARNs - all clusters by default"
  type        = list(string)
  default     = ["arn:aws:rds:*:*:cluster:*"]
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
