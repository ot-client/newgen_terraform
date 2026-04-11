output "launch_template_ids" {
  description = "Map of launch template names to IDs"
  value       = { for k, v in aws_launch_template.template : k => v.id }
}

output "launch_template_names" {
  description = "List of launch template names"
  value       = [ for k, v in aws_launch_template.template : v.name ]
}
