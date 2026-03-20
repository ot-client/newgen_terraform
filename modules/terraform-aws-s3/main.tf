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

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      expiration {
        days = try(rule.value.expiration_days, null)
      }
    }
  }
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
    var.attach_cloudtrail_policy ? data.aws_iam_policy_document.cloudtrail[0].json : ""
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
  count                 = local.create_bucket && length(var.server_side_encryption_configuration) > 0 ? 1 : 0
  bucket                = aws_s3_bucket.main[0].id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
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
  count                 = local.create_bucket && var.versioning.enabled ? 1 : 0
  bucket                = aws_s3_bucket.main[0].id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  versioning_configuration {
    status     = var.versioning.status
    mfa_delete = var.versioning.mfa_delete ? "Enabled" : "Disabled"
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

resource "aws_s3_bucket_replication_configuration" "crr" {
  count = local.create_bucket && var.crr_enabled ? 1 : 0

  bucket = aws_s3_bucket.main[0].id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "crr-rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = var.replication_destination_arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_iam_role" "replication" {
  name = lower("${var.name}-replication-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(
    { Name = lower("${var.name}-replication-role") },
    local.common_tags
  )
}

resource "aws_iam_role_policy" "replication_policy" {
  for_each = var.s3_buckets # iterate over all buckets

  name = "${each.value.name}-replication-role"
  role = aws_iam_role.replication[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main[each.key].arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetObjectRetention",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          "${aws_s3_bucket.main[each.key].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = [
          "arn:aws:s3:::${var.replication_destination_bucket[each.key]}",
          "arn:aws:s3:::${var.replication_destination_bucket[each.key]}/*"
        ]
      }
    ]
  })
}
