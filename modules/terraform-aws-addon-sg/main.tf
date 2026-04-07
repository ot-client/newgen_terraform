resource "aws_security_group" "this" {
  name        = var.name
  description = var.name
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "this" {
  for_each = var.rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_sg_id", null)

  description = lookup(each.value, "description", null)
}

resource "aws_network_interface_sg_attachment" "this" {
  for_each = var.eni_ids

  security_group_id    = aws_security_group.this.id
  network_interface_id = each.value
}