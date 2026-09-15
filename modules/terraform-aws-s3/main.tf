data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}


resource "aws_s3_bucket" "main" {
  count               = local.create_bucket ? 1 : 0
  bucket              = lower(var.name)
  bucket_prefix       = var.name == null ? var.bucket_prefix : null
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags = merge(
    { Name = var.name },
    local.common_tags
  )
}


resource "aws_s3_bucket_accelerate_configuration" "acceleration" {
  count  = local.create_bucket && var.enable_transfer_acceleration ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].bucket
  status = var.enable_transfer_acceleration ? "Enabled" : "Suspended"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count                   = local.create_bucket && var.attach_public_policy ? 1 : 0
  bucket                  = aws_s3_bucket.main[0].id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count      = local.create_bucket && local.attach_policy ? 1 : 0
  bucket     = aws_s3_bucket.main[0].id
  policy     = data.aws_iam_policy_document.combined[0].json
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

data "aws_iam_policy_document" "combined" {
  count = local.create_bucket && local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_iam_policy ? var.iam_policy : "",
    var.attach_iam_policy ? data.aws_iam_policy_document.s3denyssl[0].json : "",
    var.attach_cloudtrail_policy ? data.aws_iam_policy_document.cloudtrail[0].json : "",
    var.bucket_policy != null ? var.bucket_policy : ""
  ])
}

data "aws_iam_policy_document" "s3denyssl" {
  count = var.attach_iam_policy ? 1 : 0

  statement {
    sid = "DenyNonSSLRequests"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.main[0].arn,
      "${aws_s3_bucket.main[0].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.create_bucket && var.attach_elb_log_delivery_policy ? 1 : 0

  dynamic "statement" {
    for_each = { for k, v in var.elb_service_accounts : k => v if k == data.aws_region.current.id }

    content {
      sid = format("ELBRegion%s", title(statement.key))

      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }

      effect  = "Allow"
      actions = ["s3:PutObject"]

      resources = [
        aws_s3_bucket.main[count.index].arn,
        "${aws_s3_bucket.main[count.index].arn}/${var.log_delivery_folder}/elb-logs/*",
      ]
    }
  }

  statement {
    sid = "ELBRegionOverride"

    principals {
      type        = "Service"
      identifiers = [var.elb_identifier]
    }

    effect  = "Allow"
    actions = ["s3:PutObject"]

    resources = [
      aws_s3_bucket.main[count.index].arn,
      "${aws_s3_bucket.main[count.index].arn}/${var.log_delivery_folder}/",
    ]
  }
}

data "aws_iam_policy_document" "cloudtrail" {
  count = local.create_bucket && var.attach_cloudtrail_policy ? 1 : 0

  statement {
    sid     = "AllowCloudTrailToGetBucketAcl"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl", "s3:GetBucketLocation", "s3:PutObject"]

    resources = [
      aws_s3_bucket.main[0].arn,
      "${aws_s3_bucket.main[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.create_bucket && var.attach_lb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AllowLoadBalancerLogging"

    principals {
      type        = "Service"
      identifiers = [var.lb_identifier]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.main[0].arn,
      "${aws_s3_bucket.main[0].arn}/${var.log_delivery_folder}/alb-logs/*"
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  count  = local.create_bucket && var.control_object_ownership ? 1 : 0
  bucket = local.attach_policy ? aws_s3_bucket_policy.bucket_policy[0].id : aws_s3_bucket.main[0].id
  rule {
    object_ownership = var.object_ownership
  }
  depends_on = [
    aws_s3_bucket_policy.bucket_policy,
    aws_s3_bucket_public_access_block.public_access_block,
    aws_s3_bucket.main
  ]
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count = local.create_bucket && local.create_bucket_acl && var.object_ownership != "BucketOwnerEnforced" ? 1 : 0

  bucket                = aws_s3_bucket.main[0].id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  acl                   = var.acl == "null" ? null : var.acl
  depends_on            = [aws_s3_bucket_ownership_controls.ownership_controls]
}


resource "aws_s3_bucket_cors_configuration" "cors" {
  count                 = local.create_bucket && local.create_bucket_acl && var.object_ownership != "BucketOwnerEnforced" ? 1 : 0
  bucket                = aws_s3_bucket.main[0].id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  dynamic "cors_rule" {
    for_each = local.cors_rules
    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = local.create_bucket && length(var.server_side_encryption_configuration) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main[0].id
  dynamic "rule" {
    for_each = var.server_side_encryption_configuration
    content {
      bucket_key_enabled = try(rule.value.bucket_key_enabled, null)
      apply_server_side_encryption_by_default {
        sse_algorithm     = rule.value.apply_server_side_encryption_by_default.sse_algorithm
        kms_master_key_id = rule.value.apply_server_side_encryption_by_default.kms_master_key_id
      }
    }
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = local.create_bucket && (
    try(var.logging["target_bucket"], null) != null &&
    try(var.logging["target_bucket"], "") != ""
  ) ? 1 : 0

  bucket        = aws_s3_bucket.main[0].id
  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], "")
}



resource "aws_s3_bucket_versioning" "versioning" {
  count  = local.create_bucket && var.versioning.enabled ? 1 : 0
  bucket = aws_s3_bucket.main[0].id
  versioning_configuration {
    status     = local.versioning_status
    mfa_delete = "Disabled"
  }
}

resource "aws_s3_bucket_metric" "metrics" {
  for_each = { for metric in var.metric_configuration : metric.id => metric }
  bucket   = aws_s3_bucket.main[0].id
  name     = each.value.name
  dynamic "filter" {
    for_each = each.value.filter
    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }
}


resource "aws_s3_bucket_website_configuration" "website" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_iam_role" "replication" {
  count = local.create_bucket && length([for r in var.replication_rules : r if r.enabled]) > 0 ? 1 : 0
  name  = "s3-replication-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  count = local.create_bucket && length([for r in var.replication_rules : r if r.enabled]) > 0 ? 1 : 0
  name  = "s3-replication-policy-${var.name}"
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.main[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.main[0].arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = [for r in var.replication_rules : "arn:aws:s3:::${r.destination_bucket}/*" if r.enabled]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count  = local.create_bucket && length([for r in var.replication_rules : r if r.enabled]) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main[0].id
  role   = aws_iam_role.replication[0].arn

  depends_on = [aws_s3_bucket_versioning.versioning]

  dynamic "rule" {
    for_each = [for r in var.replication_rules : r if r.enabled]
    content {
      # Replication rule name (Up to 255 characters)
      id = rule.value.id

      # Status: Enabled | Disabled
      status = rule.value.enabled ? "Enabled" : "Disabled"

      # Priority (resolves conflicts when object matches multiple rules)
      priority = try(rule.value.priority, 0)

      # ── Choose a rule scope ───────────────────────────────────────────────────
      # An explicit filter block is always required to use V2 replication schema
      # (needed for delete_marker_replication). Empty filter = apply to all objects.
      filter {
        dynamic "and" {
          for_each = try(rule.value.prefix, null) != null && try(rule.value.tags, null) != null ? [1] : []
          content {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
        prefix = (
          try(rule.value.tags, null) == null &&
          try(rule.value.prefix, null) != null
        ) ? rule.value.prefix : null
        dynamic "tag" {
          for_each = try(rule.value.prefix, null) == null && try(rule.value.tags, null) != null ? rule.value.tags : {}
          content {
            key   = tag.key
            value = tag.value
          }
        }
      }

      # ── Destination ────────────────────────────────────────────────────────────
      destination {
        bucket        = "arn:aws:s3:::${rule.value.destination_bucket}"
        storage_class = try(rule.value.change_storage_class, false) ? try(rule.value.destination_storage_class, null) : null
        # Cross-account: specify destination account ID so AWS verifies bucket ownership
        account = try(rule.value.cross_account_replication, false) ? try(rule.value.destination_account_id, null) : null

        # ── Encryption ──────────────────────────────────────────────────────────
        dynamic "encryption_configuration" {
          for_each = try(rule.value.replicate_kms_encrypted_objects, false) && try(rule.value.kms_key_id, null) != null ? [1] : []
          content {
            replica_kms_key_id = rule.value.kms_key_id
          }
        }

        # ── Replication Time Control (RTC) ────────────────────────────────────────
        dynamic "replication_time" {
          for_each = try(rule.value.replication_time_control, false) ? [1] : []
          content {
            status = "Enabled"
            time { minutes = 15 }
          }
        }

        # ── Replication metrics ───────────────────────────────────────────────────
        dynamic "metrics" {
          for_each = try(rule.value.replication_metrics, false) ? [1] : []
          content {
            status = "Enabled"
            event_threshold { minutes = 15 }
          }
        }
      }

      # ── Delete marker replication ───────────────────────────────────────────────
      delete_marker_replication {
        status = try(rule.value.delete_marker_replication, false) ? "Enabled" : "Disabled"
      }

      # ── Replica modification sync ───────────────────────────────────────────────
      dynamic "source_selection_criteria" {
        for_each = try(rule.value.replica_modification_sync, false) || try(rule.value.replicate_kms_encrypted_objects, false) ? [1] : []
        content {
          dynamic "replica_modifications" {
            for_each = try(rule.value.replica_modification_sync, false) ? [1] : []
            content { status = "Enabled" }
          }
          dynamic "sse_kms_encrypted_objects" {
            for_each = try(rule.value.replicate_kms_encrypted_objects, false) ? [1] : []
            content { status = "Enabled" }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = local.create_bucket && length([for r in var.lifecycle_rules : r if r.enabled]) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  dynamic "rule" {
    for_each = [for r in var.lifecycle_rules : r if r.enabled]
    content {
      id     = rule.value.id
      status = "Enabled"

      # Filter block
      dynamic "filter" {
        for_each = (
          try(rule.value.prefix, null) != null ||
          try(rule.value.tags, null) != null ||
          try(rule.value.min_object_size, null) != null ||
          try(rule.value.max_object_size, null) != null
        ) ? [1] : []
        content {
          dynamic "and" {
            for_each = (
              (try(rule.value.tags, null) != null && length(try(rule.value.tags, {})) > 0) ||
              try(rule.value.min_object_size, null) != null ||
              try(rule.value.max_object_size, null) != null
            ) ? [1] : []
            content {
              prefix                   = try(rule.value.prefix, null)
              tags                     = try(rule.value.tags, null)
              object_size_greater_than = try(rule.value.min_object_size, null)
              object_size_less_than    = try(rule.value.max_object_size, null)
            }
          }
          dynamic "tag" {
            for_each = (
              try(rule.value.tags, null) != null &&
              length(try(rule.value.tags, {})) == 1 &&
              try(rule.value.min_object_size, null) == null &&
              try(rule.value.max_object_size, null) == null
            ) ? rule.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
          prefix = (
            try(rule.value.tags, null) == null &&
            try(rule.value.min_object_size, null) == null &&
            try(rule.value.max_object_size, null) == null
          ) ? try(rule.value.prefix, null) : null
        }
      }

      # Transition current versions
      dynamic "transition" {
        for_each = try(rule.value.transition_current_versions, false) ? try(rule.value.current_version_transitions, []) : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Transition noncurrent versions
      dynamic "noncurrent_version_transition" {
        for_each = try(rule.value.transition_noncurrent_versions, false) ? try(rule.value.noncurrent_version_transitions, []) : []
        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          storage_class             = noncurrent_version_transition.value.storage_class
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
        }
      }

      # Expire current versions
      dynamic "expiration" {
        for_each = try(rule.value.expire_current_versions, false) && try(rule.value.current_version_expiration, null) != null ? [rule.value.current_version_expiration] : []
        content {
          days = expiration.value.days
        }
      }

      # Expire noncurrent versions
      dynamic "noncurrent_version_expiration" {
        for_each = try(rule.value.expire_noncurrent_versions, false) && try(rule.value.noncurrent_version_expiration, null) != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
        }
      }

      # Delete expired object delete markers
      dynamic "expiration" {
        for_each = try(rule.value.delete_expired_markers, false) && try(rule.value.expired_object_delete_marker, false) ? [1] : []
        content {
          expired_object_delete_marker = true
        }
      }

      # Abort incomplete multipart uploads
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.delete_expired_markers, false) && try(rule.value.abort_incomplete_multipart_upload_days, null) != null ? [1] : []
        content {
          days_after_initiation = rule.value.abort_incomplete_multipart_upload_days
        }
      }
    }
  }
}
