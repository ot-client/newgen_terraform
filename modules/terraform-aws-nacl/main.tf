locals {
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}

resource "aws_network_acl" "nacls" {
  for_each = var.nacls

  vpc_id     = var.vpc_id
  subnet_ids = each.value.subnet_ids

  tags = merge({ Name = each.key }, local.common_tags)

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }
}
