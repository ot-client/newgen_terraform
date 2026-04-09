# ── ACM Certificate Import ────────────────────────────────────────
# Client provides: certificate_body, private_key, certificate_chain (optional)
# Each certificate in var.certificates is imported into ACM.

resource "aws_acm_certificate" "this" {
  for_each = { for idx, cert in var.certificates : idx => cert }

  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = lookup(each.value, "certificate_chain", null)

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
