output "certificate_arns" {
  description = "ARNs of imported ACM certificates — attach to ALB HTTPS listener"
  value       = [for cert in aws_acm_certificate.this : cert.arn]
}
