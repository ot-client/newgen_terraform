# -------------------------------------------------------------------
# Backup Vault - AWS Default encryption (no custom KMS key)
# -------------------------------------------------------------------
resource "aws_backup_vault" "this" {
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

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# -------------------------------------------------------------------
# Backup Plan
# -------------------------------------------------------------------
resource "aws_backup_plan" "this" {
  name = var.plan_name

  rule {
    rule_name                = var.rule_name
    target_vault_name        = aws_backup_vault.this.name
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
# Backup_1 - EC2: All Instances
#   Resource type : EC2 instances (all)
#   Refine by tag : Backup=True (do NOT tag EKS cluster nodes)
# -------------------------------------------------------------------
resource "aws_backup_selection" "ec2" {
  name         = var.ec2_assignment_name
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  # Select specific resource type: EC2 - All Instances
  resources = var.ec2_resource_arns

  # Refine selection using tag: Key=Backup, Value=True
  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.ec2_tag_key
    value = var.ec2_tag_value
  }
}

# -------------------------------------------------------------------
# Backup_2 - Aurora: All Clusters
#   Resource type : RDS Aurora clusters (all)
#   Refine by tag : Backup=True
# -------------------------------------------------------------------
resource "aws_backup_selection" "aurora" {
  name         = var.aurora_assignment_name
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  # Select specific resource type: Aurora clusters
  resources = var.aurora_resource_arns

  # Refine selection using tag: Key=Backup, Value=True
  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.aurora_tag_key
    value = var.aurora_tag_value
  }
}
