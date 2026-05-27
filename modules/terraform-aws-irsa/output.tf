output "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider"
  value       = local.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC identity provider"
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.identity_provider[0].url : var.existing_oidc_provider_arn
}

output "irsa_role_arns" {
  description = "Map of IRSA role names to ARNs"
  value       = { for k, v in aws_iam_role.irsa : k => v.arn }
}
