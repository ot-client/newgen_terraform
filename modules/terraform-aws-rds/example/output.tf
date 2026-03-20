output "db_instance_endpoint" {
  value = try(module.rds.db_instance_endpoint, null)
}

output "rds_cluster_endpoint" {
  value = try(module.rds.rds_cluster_endpoint, null)
}

output "rds_proxy_endpoint" {
  value = try(module.rds.rds_proxy_endpoint, null)
}

output "security_rds_group_id" {
  description = "ID of the ElastiCache security group"
  value       = var.enable_public_rds_security_group_resource ? module.rds_security_group[0].id[0] : null
}

output "security_ec2_group_id" {
  description = "ID of the ElastiCache security group"
  value       = var.enable_public_ec2_security_group_resource ? module.ec2_security_group[0].id[0] : null
}

output "ec2_instance_ids" {
  value = module.ec2_with_optional_ebs.ec2_instance_ids
}