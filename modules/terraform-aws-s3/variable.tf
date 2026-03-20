
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

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id              = string
    status          = string
    expiration_days = optional(number)
    transitions = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = [
    {
      id     = "log-transition"
      status = "Enabled"

      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      expiration_days = 365
    }
  ]
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



variable "replication_destination_arn" {
  description = "Destination bucket ARN for CRR"
  type        = string
  default     = "*"
}

variable "crr_enabled" {
  default = false
}

variable "replication_destination_bucket" {
  description = "Map of destination buckets for CRR"
  type        = map(string)
  default     = {}
}




################################## Naming Convention Variables #########################################

# variable "env" {
#   type    = string
#   default = "dev"
#
# }

variable "owner" {
  type    = string
  default = "opstree"
}

# variable "app" {
#   type    = string
#   default = "otcloud-kit"
#
# }

variable "instance_sg_id" {
  type        = string
  default     = ""
  description = " SG IDs to attach to the EC2 instance"
}

variable "s3_buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name                     = string
    force_destroy            = bool
    control_object_ownership = bool
    object_ownership         = string
    attach_public_policy     = bool
    block_public_acls        = bool
    block_public_policy      = bool
    ignore_public_acls       = bool
    restrict_public_buckets  = bool
    versioning = object({
      enabled    = bool
      status     = string
      mfa_delete = bool
    })
    server_side_encryption_configuration = list(object({
      bucket_key_enabled = optional(bool)
      apply_server_side_encryption_by_default = object({
        sse_algorithm     = string
        kms_master_key_id = optional(string)
      })
    }))
    tags = map(string)
  }))
  default = {}
}
