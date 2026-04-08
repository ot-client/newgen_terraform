# Returns the list of validated ARNs — attach directly to ALB HTTPS listener
output "certificate_arns" {
  description = "ACM certificate ARNs validated and ready for ALB attachment"
  value       = [for cert in data.aws_acm_certificate.this : cert.arn]
}
