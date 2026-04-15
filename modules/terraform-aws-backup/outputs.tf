output "vault_arn" {
  value = aws_backup_vault.vault.arn
}

output "plan_id" {
  value = aws_backup_plan.plan.id
}

output "iam_role_arn" {
  value = local.iam_role_arn
}
