
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

# variable "program" {
#   description = "Project/Program name"
#   type        = string
#   default     = ""
# }

# variable "s3_tags" {
#   description = "Tag for S3 specific resources"
#   type        = string
#   default     = ""
# }

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

variable "bucket_policy" {
  description = "Custom bucket policy JSON string. Set to null to skip."
  type        = string
  default     = null
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
    enabled = bool
  })
  default = {
    enabled = false
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



variable "replication_rules" {
  description = "List of replication rules (AWS Console -> S3 -> Management -> Replication rules)"
  type = list(object({
    # ── Replication rule configuration ────────────────────────────────────────
    # Replication rule name (Up to 255 characters)
    id = string

    # Status: Enabled | Disabled
    enabled = bool

    # Priority (resolves conflicts when object matches multiple rules)
    priority = optional(number)

    # ── Choose a rule scope ───────────────────────────────────────────────────
    # "Apply to all objects in the bucket" -> set prefix and tags to null
    # "Limit the scope using one or more filters" -> set prefix or tags below
    prefix = optional(string) # Prefix filter
    tags   = optional(map(string)) # Object tags filter

    # ── Destination ───────────────────────────────────────────────────────────
    # Bucket name that will receive replicated objects
    destination_bucket = string # Destination bucket name (same or different account)

    # Cross-account replication
    # cross_account_replication = false -> same account (destination_account_id ignored)
    # cross_account_replication = true  -> different account (destination_account_id required)
    cross_account_replication = optional(bool)   # true | false
    destination_account_id    = optional(string) # Destination AWS account ID (required if cross_account_replication = true)

    # IAM role ARN for replication permissions
    # iam_role_arn = "Create new role" -> leave null to auto-create, or provide ARN
    iam_role_arn = optional(string)

    # ── Encryption ────────────────────────────────────────────────────────────
    # Replicate objects encrypted with AWS KMS (SSE-KMS / DSSE-KMS)
    replicate_kms_encrypted_objects = optional(bool) # true | false
    kms_key_id                      = optional(string) # Destination KMS key ARN (required if replicate_kms_encrypted_objects = true)

    # ── Destination storage class ─────────────────────────────────────────────
    # Change the storage class for the replicated objects
    # true = change storage class | false = keep same as source
    change_storage_class  = optional(bool)
    destination_storage_class = optional(string) # STANDARD | STANDARD_IA | ONEZONE_IA | INTELLIGENT_TIERING | GLACIER | DEEP_ARCHIVE

    # ── Additional replication options ────────────────────────────────────────
    # Replication Time Control (RTC) - replicates 99.99% of objects within 15 minutes
    replication_time_control = optional(bool) # true | false (additional fees apply)

    # Replication metrics - monitor pending replication objects and failures
    replication_metrics = optional(bool) # true | false (CloudWatch fees apply)

    # Delete marker replication - replicate delete markers created by S3 delete operations
    delete_marker_replication = optional(bool) # true | false

    # Replica modification sync - replicate metadata changes from destination back to source
    replica_modification_sync = optional(bool) # true | false
  }))
  default = []
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    enabled = bool
    id      = string

    # Filter (all optional - if none set, applies to all objects)
    prefix          = optional(string)
    tags            = optional(map(string))
    min_object_size = optional(number)
    max_object_size = optional(number)

    # Action flags
    transition_current_versions    = optional(bool) # Transition current versions of objects between storage classes
    transition_noncurrent_versions = optional(bool) # Transition noncurrent versions of objects between storage classes
    expire_current_versions        = optional(bool) # Expire current versions of objects
    expire_noncurrent_versions     = optional(bool) # Permanently delete noncurrent versions of objects
    delete_expired_markers         = optional(bool) # Delete expired object delete markers or incomplete multipart uploads

    # Transition current versions config (used when transition_current_versions = true)
    current_version_transitions = optional(list(object({
      days          = number
      storage_class = string # STANDARD_IA | ONEZONE_IA | INTELLIGENT_TIERING | GLACIER | DEEP_ARCHIVE
    })))

    # Transition noncurrent versions config (used when transition_noncurrent_versions = true)
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days           = number
      storage_class             = string
      newer_noncurrent_versions = optional(number)
    })))

    # Expire current versions config (used when expire_current_versions = true)
    current_version_expiration = optional(object({
      days = number
    }))

    # Expire noncurrent versions config (used when expire_noncurrent_versions = true)
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number) # keep last N noncurrent versions
    }))

    # Delete markers / incomplete multipart (used when delete_expired_markers = true)
    expired_object_delete_marker           = optional(bool)
    abort_incomplete_multipart_upload_days = optional(number)
  }))
  default = []
}


