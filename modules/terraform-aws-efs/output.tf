# ─── New EFS ──────────────────────────────────────────────────────────────────

output "efs_ids" {
  description = "Map of new EFS file system IDs keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.id }
}

output "efs_arns" {
  description = "Map of new EFS ARNs keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.arn }
}

output "efs_dns_names" {
  description = "Map of new EFS DNS names keyed by config name"
  value       = { for k, v in aws_efs_file_system.main : k => v.dns_name }
}

output "access_point_ids" {
  description = "Map of access point IDs"
  value       = { for k, v in aws_efs_access_point.ap : k => v.id }
}

output "mount_target_ids" {
  description = "Map of new EFS mount target IDs"
  value       = { for k, v in aws_efs_mount_target.target : k => v.id }
}

# output "efs_user_data" {
#  description = "Map of rendered user-data scripts for new EFS volumes (requires mount_point set)"
#  value       = { for k, v in data.template_file.efs_user_data : k => v.rendered }
# }

# ─── Existing EFS ─────────────────────────────────────────────────────────────

output "existing_efs_mount_target_ids" {
  description = "List of mount target IDs created for existing EFS volumes"
  value       = aws_efs_mount_target.existing[*].id
}

# output "existing_efs_user_data" {
#  description = "List of rendered user-data scripts for existing EFS volumes"
#  value       = data.template_file.existing_efs_user_data[*].rendered
#}

# ─── Security Group ───────────────────────────────────────────────────────────

output "security_group_id" {
  description = "ID of the EFS security group (null if create_security_group = false)"
  value       = var.create_security_group ? aws_security_group.efs_sg[0].id : null
}
