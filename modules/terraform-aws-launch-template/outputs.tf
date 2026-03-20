output "launch_template_id" {
  value       = aws_launch_template.template.id
  description = "ID of the launch template"
}

output "launch_template_name" {
  value       = aws_launch_template.template.name
  description = "Name of the launch template"
}
