# -------------------------------------------------------------------
# Backup Vault - AWS Default encryption (no custom KMS key)
# -------------------------------------------------------------------
resource "aws_backup_vault" "vault" {
  name        = var.vault_name
  kms_key_arn = var.kms_key_arn  # null = AWS managed default key
  tags        = merge({ Name = var.vault_name }, var.tags)
}

# -------------------------------------------------------------------
# IAM Role - shared by both Backup_1 (EC2) and Backup_2 (Aurora)
# -------------------------------------------------------------------
resource "aws_iam_role" "backup" {
  name = var.iam_role_name

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
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
  ])

  role       = aws_iam_role.backup.name
  policy_arn = each.value
}

# -------------------------------------------------------------------
# Backup Plan
# -------------------------------------------------------------------
resource "aws_backup_plan" "plan" {
  name = var.plan_name

  rule {
    rule_name                = var.rule_name
    target_vault_name        = aws_backup_vault.vault.name
    schedule                 = "cron(${var.schedule_minute} ${var.schedule_hour} * * ? *)"
    schedule_expression_timezone = var.schedule_timezone

    start_window      = var.start_window_minutes
    completion_window = var.completion_window_minutes

    # Cold storage: Disabled - no cold_storage_after set
    # PITR (Point-in-time recovery): Disabled by default
    lifecycle {
      delete_after = var.retention_days
    }
  }

  tags = merge({ Name = var.plan_name }, var.tags)
}

# -------------------------------------------------------------------
# Backup Selections - driven entirely by var.selections from tfvars
# -------------------------------------------------------------------
resource "aws_backup_selection" "assignments" {
  for_each = var.selections

  name         = each.value.name
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.plan.id
  resources    = each.value.resource_arns

  selection_tag {
    type  = "STRINGEQUALS"
    key   = each.value.tag_key
    value = each.value.tag_value
  }
}
