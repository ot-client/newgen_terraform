output "secret_arn" {
  description = "ARN of the created secret."
  value       = try(aws_secretsmanager_secret.secret[0].arn, "")
}

output "secret_id" {
  description = "ID (ARN) of the created secret."
  value       = try(aws_secretsmanager_secret.secret[0].id, "")
}

output "secret_name" {
  description = "Name of the created secret."
  value       = try(aws_secretsmanager_secret.secret[0].name, "")
}

output "secret_version_id" {
  description = "Version ID of the secret value stored."
  value       = try(aws_secretsmanager_secret_version.secret_version[0].version_id, "")
}
