# -------------------------------------------------------
# Route53 Resolver Rule + VPC Association
# Use-case: Admin account shares VPC into customer account.
#           Customer creates a Resolver Rule and attaches
#           that (or any) VPC so DNS queries are forwarded.
# -------------------------------------------------------

resource "aws_route53_resolver_rule" "this" {
  for_each = { for rule in var.resolver_rules : rule.name => rule }

  domain_name          = each.value.domain_name
  rule_type            = each.value.rule_type   # FORWARD | SYSTEM | RECURSIVE
  resolver_endpoint_id = each.value.rule_type == "FORWARD" ? each.value.resolver_endpoint_id : null
  name                 = each.key

  dynamic "target_ip" {
    for_each = each.value.rule_type == "FORWARD" ? each.value.target_ips : []
    content {
      ip   = target_ip.value.ip
      port = lookup(target_ip.value, "port", 53)
    }
  }

  tags = merge({ Name = each.key }, var.tags)
}

resource "aws_route53_resolver_rule_association" "this" {
  for_each = {
    for assoc in flatten([
      for rule in var.resolver_rules : [
        for vpc_id in rule.vpc_ids : {
          key     = "${rule.name}-${vpc_id}"
          name    = rule.name
          vpc_id  = vpc_id
        }
      ]
    ]) : assoc.key => assoc
  }

  resolver_rule_id = aws_route53_resolver_rule.this[each.value.name].id
  vpc_id           = each.value.vpc_id
}
