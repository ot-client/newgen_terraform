resource "aws_lb" "application_load_balancer" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  ip_address_type    = var.ip_address_type
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  tags = var.tags
}
