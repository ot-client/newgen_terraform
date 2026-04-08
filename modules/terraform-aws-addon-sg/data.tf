# Enhanced data sources for specific service targeting

# RDS Cluster ENI IDs (specific clusters)
data "aws_rds_cluster" "specific_clusters" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "rds_clusters", [])
  ]))
  
  cluster_identifier = each.value
}

# RDS Instance ENI IDs (specific instances)
data "aws_db_instance" "specific_instances" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "rds_instances", [])
  ]))
  
  db_instance_identifier = each.value
}

# EFS Mount Targets (specific filesystems by ID only)
data "aws_efs_mount_target" "specific_efs" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "efs_filesystems", [])
  ]))
  
  file_system_id = each.value
}

# Redis/ElastiCache (specific clusters)
data "aws_elasticache_replication_group" "specific_redis" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "redis_clusters", [])
  ]))
  
  replication_group_id = each.value
}

# EKS Clusters (specific clusters)
data "aws_eks_cluster" "specific_eks" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "eks_clusters", [])
  ]))
  
  name = each.value
}

# EC2 Instances (specific instances)
data "aws_instance" "specific_ec2" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "ec2_instances", [])
  ]))
  
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# VPC Endpoints (specific endpoints)
data "aws_vpc_endpoint" "specific_endpoints" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups : 
    lookup(lookup(sg_config, "service_attachments", {}), "vpc_endpoints", [])
  ]))
  
  id = each.value
}