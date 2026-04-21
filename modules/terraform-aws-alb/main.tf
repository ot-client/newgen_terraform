# ═══════════════════════════════════════════════════════════════
# SECURITY GROUP
# ═══════════════════════════════════════════════════════════════

resource "aws_security_group" "alb_sg" {
  count  = var.create_security_group ? 1 : 0
  name   = var.security_group_name
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = var.security_group_name })
}

locals {
  security_group_id = var.create_security_group ? aws_security_group.alb_sg[0].id : var.existing_security_group_id
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create_security_group ? length(var.ingress_rules) : 0
  security_group_id = local.security_group_id
  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  description       = var.ingress_rules[count.index].description
}

resource "aws_security_group_rule" "egress_all" {
  count             = var.create_security_group && var.egress_allow_all ? 1 : 0
  security_group_id = local.security_group_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound"
}

resource "aws_security_group_rule" "egress" {
  count             = var.create_security_group && !var.egress_allow_all ? length(var.egress_rules) : 0
  security_group_id = local.security_group_id
  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  description       = var.egress_rules[count.index].description
}

# ═══════════════════════════════════════════════════════════════
# APPLICATION LOAD BALANCER
# ═══════════════════════════════════════════════════════════════

resource "aws_lb" "application_load_balancer" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  ip_address_type    = var.ip_address_type
  subnets            = var.subnet_ids
  security_groups    = [local.security_group_id]

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }

  tags = var.tags

  depends_on = [
    aws_security_group.alb_sg,
    aws_security_group_rule.ingress,
    aws_security_group_rule.egress_all,
    aws_security_group_rule.egress,
  ]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  dynamic "default_action" {
    for_each = var.target_group_arn != "" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = var.target_group_arn
    }
  }

  dynamic "default_action" {
    for_each = var.target_group_arn == "" ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Service unavailable"
        status_code  = "503"
      }
    }
  }

  tags = var.tags
}
