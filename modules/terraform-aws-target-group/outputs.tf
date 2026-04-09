output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.application_target_group.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.application_target_group.name
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.application_target_group.id
}
