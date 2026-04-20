output "redis_replication_group_id" {
  value       = aws_elasticache_replication_group.cluster.id
  description = "Redis replication group ID"
}
output "redis_primary_endpoint" {
  value       = aws_elasticache_replication_group.cluster.primary_endpoint_address
  description = "Primary endpoint (write)"
}
output "redis_reader_endpoint" {
  value       = aws_elasticache_replication_group.cluster.reader_endpoint_address
  description = "Reader endpoint (read)"
}
output "security_group_id" {
  value       = var.create_default_security_group ? aws_security_group.cache_sg[0].id : null
  description = "SG created by module (null if using existing)"
}
output "subnet_group_name" {
  value       = local.subnet_grp
  description = "Subnet group name used"
}
