# Cluster endpoint for application connection
output "cluster_endpoint" {
  value       = aws_rds_cluster.rds.endpoint
  description = "The endpoint of the RDS cluster"
}

# Reader endpoint for read replicas
output "reader_endpoint" {
  value       = aws_rds_cluster.rds.reader_endpoint
  description = "The reader endpoint for the RDS cluster"
}

# Cluster ID
output "cluster_id" {
  value       = aws_rds_cluster.rds.id
  description = "The ID of the RDS cluster"
}

# Cluster ARN
output "cluster_arn" {
  value       = aws_rds_cluster.rds.arn
  description = "The ARN of the RDS cluster"
}

# Cluster port
output "cluster_port" {
  value       = aws_rds_cluster.rds.port
  description = "The port on which the RDS cluster is listening"
}

# Instance IDs
output "instance_ids" {
  value       = aws_rds_cluster_instance.rds_instance[*].id
  description = "IDs of all RDS cluster instances"
}
