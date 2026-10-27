resource "aws_network_acl" "nacls" {
  for_each = var.nacl_rules

  vpc_id     = var.vpc_id
  subnet_ids = [for idx in var.nacl_subnet_map[each.key] : var.subnet_ids[idx]]

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = merge(var.tags, { Name = each.key })
}
