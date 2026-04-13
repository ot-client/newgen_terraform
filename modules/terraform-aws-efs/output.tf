output "efs_ids" {
  description = "Map of EFS file system IDs keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.id }
}

output "efs_arns" {
  description = "Map of EFS ARNs keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.arn }
}

output "efs_dns_names" {
  description = "Map of EFS DNS names keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.dns_name }
}

output "access_point_ids" {
  description = "Map of access point IDs"
  value       = { for k, v in aws_efs_access_point.ap : k => v.id }
}

output "mount_target_ids" {
  description = "Map of EFS mount target IDs"
  value       = { for k, v in aws_efs_mount_target.target : k => v.id }
}

output "security_group_ids" {
  description = "Map of EFS security group IDs"
  value       = { for k, v in aws_security_group.efs : k => v.id }
}
