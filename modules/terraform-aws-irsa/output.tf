output "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC identity provider"
  value       = aws_iam_openid_connect_provider.this.url
}

output "irsa_role_arns" {
  description = "Map of IRSA role names to ARNs"
  value       = { for k, v in aws_iam_role.irsa : k => v.arn }
}
