data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(var.tags, { Name = each.value.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for item in flatten([
      for sg_key, sg in var.security_groups : [
        for idx, rule in sg.ingress_rules : {
          key         = "${sg_key}-ingress-${idx}"
          sg_key      = sg_key
          from_port   = rule.from_port
          to_port     = rule.to_port
          ip_protocol = rule.protocol
          cidr_ipv4   = length(rule.cidr_blocks) > 0 ? rule.cidr_blocks[0] : null
          description = rule.description
        }
      ]
    ]) : item.key => item
  }

  security_group_id = aws_security_group.this[each.value.sg_key].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  for_each = {
    for sg_key, sg in var.security_groups : sg_key => sg
    if sg.egress_allow_all == true
  }

  security_group_id = aws_security_group.this[each.key].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "custom" {
  for_each = {
    for item in flatten([
      for sg_key, sg in var.security_groups : [
        for idx, rule in sg.egress_rules : {
          key         = "${sg_key}-egress-${idx}"
          sg_key      = sg_key
          from_port   = rule.from_port
          to_port     = rule.to_port
          ip_protocol = rule.protocol
          cidr_ipv4   = length(rule.cidr_blocks) > 0 ? rule.cidr_blocks[0] : null
          description = rule.description
        }
      ] if sg.egress_allow_all == false
    ]) : item.key => item
  }

  security_group_id = aws_security_group.this[each.value.sg_key].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
  description       = each.value.description
}
