output "vault_arn" {
  value = aws_backup_vault.this.arn
}

output "plan_id" {
  value = aws_backup_plan.this.id
}

output "iam_role_arn" {
  value = aws_iam_role.backup.arn
}
