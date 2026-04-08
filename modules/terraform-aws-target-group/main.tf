resource "aws_lb_target_group" "this" {
  name             = var.name
  protocol         = var.protocol
  port             = var.port
  ip_address_type  = var.ip_address_type
  vpc_id           = var.vpc_id
  target_type      = var.target_type
  protocol_version = var.protocol_version

  health_check {
    protocol            = var.health_check_protocol
    port                = var.health_check_port
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  stickiness {
    enabled  = var.stickiness_enabled
    type     = var.stickiness_type
    cookie_duration = var.stickiness_duration
  }

  tags = merge(
    { Name = var.name },
    local.common_tags
  )
}
