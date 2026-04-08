# ── ACM Certificate Data Sources ─────────────────────────────────
# Client provides certificates externally.
# This module looks up each ARN and exposes them for ALB attachment.

data "aws_acm_certificate" "this" {
  for_each = toset(var.certificate_arns)
  arn      = each.value
}
