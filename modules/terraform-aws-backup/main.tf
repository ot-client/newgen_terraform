# -------------------------------------------------------------------
# Destination Backup Vault (cross-region)
# -------------------------------------------------------------------
resource "aws_backup_vault" "destination_vault" {
  count    = var.destination_vault_name != "" ? 1 : 0
  provider = aws.destination
  name     = var.destination_vault_name
  tags     = merge({ Name = var.destination_vault_name }, var.tags)
}

# -------------------------------------------------------------------
# Backup Vault
# -------------------------------------------------------------------
resource "aws_backup_vault" "vault" {
  name        = var.vault_name
  kms_key_arn = var.kms_key_arn
  tags        = merge({ Name = var.vault_name }, var.tags)
}

# -------------------------------------------------------------------
# IAM Role (conditional - create or use existing)
# -------------------------------------------------------------------
resource "aws_iam_role" "backup" {
  count = var.create_iam_role ? 1 : 0
  name  = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({ Name = var.iam_role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "backup_policies" {
  for_each = var.create_iam_role ? toset(var.iam_role_policies) : []

  role       = aws_iam_role.backup[0].name
  policy_arn = each.value
}

# Data source to verify existing IAM role
data "aws_iam_role" "existing" {
  count = var.create_iam_role ? 0 : 1
  name  = var.iam_role_name
}

# Add delay to ensure IAM role is fully propagated
resource "time_sleep" "wait_for_iam" {
  count = var.create_iam_role ? 0 : 1

  create_duration = "10s"

  depends_on = [data.aws_iam_role.existing]
}

locals {
  iam_role_arn = var.create_iam_role ? aws_iam_role.backup[0].arn : var.iam_role_arn
}

# -------------------------------------------------------------------
# Backup Plan with Multiple Rules
# -------------------------------------------------------------------
resource "aws_backup_plan" "plan" {
  name = var.plan_name

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = rule.value.rule_name
      target_vault_name = aws_backup_vault.vault.name
      schedule          = rule.value.schedule
      start_window      = rule.value.start_window_minutes
      completion_window = rule.value.completion_window_minutes

      lifecycle {
        delete_after = rule.value.retention_days
      }

      dynamic "copy_action" {
        for_each = var.copy_destination_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.copy_destination_vault_arn
          lifecycle {
            delete_after = rule.value.retention_days
          }
        }
      }
    }
  }

  tags = merge({ Name = var.plan_name }, var.tags)
}

# -------------------------------------------------------------------
# Backup Selections
# -------------------------------------------------------------------
resource "aws_backup_selection" "assignments" {
  for_each = var.selections

  name         = each.value.name
  iam_role_arn = local.iam_role_arn
  plan_id      = aws_backup_plan.plan.id
  resources    = length(each.value.resource_arns) > 0 ? each.value.resource_arns : null

  dynamic "selection_tag" {
    for_each = each.value.tag_key != "" ? [1] : []
    content {
      type  = "STRINGEQUALS"
      key   = each.value.tag_key
      value = each.value.tag_value
    }
  }

  depends_on = [time_sleep.wait_for_iam]
}

# -------------------------------------------------------------------
# Backup Report Plan (optional)
# -------------------------------------------------------------------
resource "aws_s3_bucket_policy" "backup_report" {
  count  = var.enable_backup_report && var.backup_report_s3_bucket != "" ? 1 : 0
  bucket = var.backup_report_s3_bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowBackupReportDelivery"
        Effect    = "Allow"
        Principal = { Service = "backup.amazonaws.com" }
        Action    = ["s3:PutObject"]
        Resource  = "arn:aws:s3:::${var.backup_report_s3_bucket}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_backup_report_plan" "report" {
  count = var.enable_backup_report && var.backup_report_s3_bucket != "" && var.backup_report_plan_name != "" ? 1 : 0

  name        = var.backup_report_plan_name
  description = "Backup audit report for ${var.plan_name}"

  report_delivery_channel {
    formats        = ["CSV", "JSON"]
    s3_bucket_name = var.backup_report_s3_bucket
  }

  report_setting {
    report_template = "BACKUP_JOB_REPORT"
  }

  tags = merge({ Name = var.backup_report_plan_name }, var.tags)
}
