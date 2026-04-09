output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.application_load_balancer.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.application_load_balancer.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = aws_lb.application_load_balancer.zone_id
}

output "alb_id" {
  description = "ID of the ALB"
  value       = aws_lb.application_load_balancer.id
}

output "listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}
