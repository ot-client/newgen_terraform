resource "aws_acm_certificate" "imported" {
  for_each = { for cert in var.certificates : cert.name => cert }

  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = each.value.certificate_chain

  tags = merge(var.tags, { Name = each.key })

  lifecycle {
    create_before_destroy = true
  }
}
