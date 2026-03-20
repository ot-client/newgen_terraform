variable "create_bucket" {
  type        = bool
  description = "Whether to create the bucket"
}

variable "name" {
  type        = string
  description = "Name of the bucket"
}

variable "bucket_prefix" {
  type        = string
  default     = null
  description = "Optional prefix for the bucket name"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Whether to force destroy the bucket"
}

variable "object_lock_enabled" {
  type    = bool
  default = false
}

variable "enable_transfer_acceleration" {
  type    = bool
  default = false
}


variable "acl" {
  type    = string
  default = null
}

variable "attach_public_policy" {
  type    = bool
  default = false
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
  type    = string
  default = ""
}

variable "control_object_ownership" {
  type    = bool
  default = true
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
}

variable "cors_rules" {
  type    = list(any)
  default = []
}

variable "server_side_encryption_configuration" {
  type    = list(any)
  default = []
}

variable "logging" {
  type    = map(string)
  default = {}
}

variable "versioning" {
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
  type    = list(any)
  default = []
}



variable "metric_configuration" {
  type    = list(any)
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
variable "crr_enabled" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}
variable "replication_destination_arn" {
  description = "Destination bucket ARN for replication"
  type        = string
  default     = "arn:aws:s3:::ot-cloud-kit-static-website"
}


variable "env" {
  type = string
  default = "dev"
  
}

variable "owner" {
  type = string
  default = "opstree"
}

variable "app" {
  type = string
  default = "otcloud-kit"
  
}
variable "region" {
  type    = string
  default = "us-east-1"
}