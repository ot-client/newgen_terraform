output "certificate_arns" {
  description = "ARNs of imported ACM certificates — attach to ALB HTTPS listener"
  value       = { for k, cert in aws_acm_certificate.imported : k => cert.arn }
}