variable "create_secret" {
  description = "Whether to create the secret. Set to false to disable all resources."
  type        = bool
  default     = true
}

variable "name" {
  description = "Full name of the secret (e.g. dev-myapp-db-password). Caller controls naming convention."
  type        = string
}

variable "description" {
  description = "Human-readable description of the secret."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN or ID of the KMS key used for encryption. Use 'aws/secretsmanager' to fall back to the AWS-managed key."
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Days AWS waits before permanently deleting the secret (0 for immediate, or 7–30)."
  type        = number
  default     = 30
}

variable "secret_string" {
  description = "Secret value. Can be a plain string or an object/map — objects are JSON-encoded automatically."
  type        = any
  default     = null
  sensitive   = true
}

variable "enable_rotation" {
  description = "Whether to enable automatic secret rotation via a Lambda function."
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function used for rotation. Required when enable_rotation = true."
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "Number of days between automatic rotations."
  type        = number
  default     = 30
}

variable "used_for_service" {
  description = "Optional tag indicating which service uses this secret (e.g. RDS, DocumentDB, Redshift)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge onto the secret resource."
  type        = map(string)
  default     = {}
}
