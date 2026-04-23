output "vault_arn" {
  value = aws_backup_vault.vault.arn
}

output "destination_vault_arn" {
  value = length(aws_backup_vault.destination_vault) > 0 ? aws_backup_vault.destination_vault[0].arn : ""
}

output "plan_id" {
  value = aws_backup_plan.plan.id
}

output "iam_role_arn" {
  value = local.iam_role_arn
}
