variable "create_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
}

variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix to prepend to the bucket name"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Force destroy the bucket on deletion"
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "Enable object lock for the bucket"
  type        = bool
  default     = false
}

variable "enable_transfer_acceleration" {
  description = "Enable S3 transfer acceleration"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "Canned ACL to apply"
  type        = string
  default     = null
}

variable "attach_public_policy" {
  description = "Attach public access block"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "attach_elb_log_delivery_policy" {
  type    = bool
  default = false
}

variable "attach_lb_log_delivery_policy" {
  type    = bool
  default = false
}

variable "attach_cloudtrail_policy" {
  type    = bool
  default = false
}

variable "attach_iam_policy" {
  type    = bool
  default = false
}

variable "iam_policy" {
  description = "Custom IAM policy document (JSON string)"
  type        = string
  default     = ""
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
}

variable "control_object_ownership" {
  type    = bool
  default = true
}

variable "cors_rules" {
  description = "List of CORS rules"
  type = list(object({
    id              = optional(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = [
    {
      id              = "AllowWebApp"
      allowed_methods = ["GET", "POST", "PUT"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

variable "server_side_encryption_configuration" {
  description = "Server-side encryption configuration block"
  type = list(object({
    bucket_key_enabled = optional(bool)
    apply_server_side_encryption_by_default = object({
      sse_algorithm     = string
      kms_master_key_id = optional(string)
    })
  }))
  default = []
}

variable "logging" {
  description = "Logging configuration"
  type = object({
    target_bucket = optional(string)
    target_prefix = optional(string)
  })
  default = {}
}

variable "versioning" {
  description = "Versioning configuration"
  type = object({
    enabled    = bool
    status     = string
    mfa_delete = bool
  })
  default = {
    enabled    = false
    status     = "Suspended"
    mfa_delete = false
  }
}

variable "metric_configuration" {
  description = "Metric configurations"
  type = list(object({
    id   = string
    name = string
    filter = list(object({
      prefix = string
      tags   = map(string)
    }))
  }))
  default = []
}

variable "elb_service_accounts" {
  type    = map(string)
  default = {}
}

variable "elb_identifier" {
  type    = string
  default = "logdelivery.elb.amazonaws.com"
}

variable "lb_identifier" {
  type    = string
  default = "logdelivery.elasticloadbalancing.amazonaws.com"
}

variable "log_delivery_folder" {
  type    = string
  default = "logs"
}

variable "lb_log_delivery_conditions" {
  type = map(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = {}
}

######################################
# CRR Variables
######################################
variable "crr_enabled" {
  description = "Enable CRR replication configuration"
  type        = bool
  default     = false
}

variable "crr_iam_role_arn" {
  description = "IAM role ARN for CRR replication"
  type        = string
  default     = ""
}

variable "crr_destination_bucket_arn" {
  description = "Destination bucket ARN for CRR"
  type        = string
  default     = ""
}

variable "replication_rule_id" {
  description = "ID for the S3 replication rule"
  type        = string
  default     = "S3-Replication-Rule-1"
}

variable "replication_status" {
  description = "Status of the replication rule"
  type        = string
  default     = "Enabled"
}

variable "delete_marker_replication_status" {
  description = "Status of delete marker replication"
  type        = string
  default     = "Disabled"
}

######################################
# Lambda Notification Variables
######################################
variable "lambda_notification_enabled" {
  description = "Enable Lambda event notification on the bucket"
  type        = bool
  default     = false
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to notify"
  type        = string
  default     = ""
}

variable "lambda_s3_event" {
  description = "S3 event type to trigger Lambda"
  type        = string
  default     = "s3:ObjectCreated:Put"
}

variable "lambda_s3_action" {
  description = "Action for the Lambda permission"
  type        = string
  default     = "lambda:InvokeFunction"
}

variable "lambda_s3_principal" {
  description = "Principal for the Lambda permission"
  type        = string
  default     = "s3.amazonaws.com"
}

variable "lambda_permission_statement_id" {
  description = "Statement ID for the Lambda permission"
  type        = string
  default     = "AllowS3Invoke"
}

######################################
# Website Variables
######################################
variable "website_enabled" {
  description = "Enable static website hosting on the bucket"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Index document for static website hosting"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for static website hosting"
  type        = string
  default     = "error.html"
}

######################################
# Policy SID Variables
######################################
variable "deny_ssl_sid" {
  description = "SID for the deny non-SSL requests statement"
  type        = string
  default     = "DenyNonSSLRequests"
}

variable "cloudtrail_policy_sid" {
  description = "SID for the CloudTrail bucket policy statement"
  type        = string
  default     = "AllowCloudTrailToGetBucketAcl"
}

variable "lb_log_delivery_sid" {
  description = "SID for the LB log delivery policy statement"
  type        = string
  default     = "AllowLoadBalancerLogging"
}

variable "elb_region_override_sid" {
  description = "SID for the ELB region override policy statement"
  type        = string
  default     = "ELBRegionOverride"
}
