# EFS Mount Target (singular — one mount target per subnet)
data "aws_efs_mount_target" "specific_efs" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "efs_filesystems", [])
  ]))

  file_system_id = each.value
}

# RDS Cluster — kept for reference only, ENI attachment not supported
# Use vpc_security_group_ids on aws_rds_cluster resource instead
data "aws_rds_cluster" "specific_clusters" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "rds_clusters", [])
  ]))

  cluster_identifier = each.value
}

# RDS Instance — kept for reference only, ENI attachment not supported
# Use vpc_security_group_ids on aws_db_instance resource instead
data "aws_db_instance" "specific_instances" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "rds_instances", [])
  ]))

  db_instance_identifier = each.value
}

# Redis/ElastiCache (specific replication groups)
data "aws_elasticache_replication_group" "specific_redis" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "redis_clusters", [])
  ]))

  replication_group_id = each.value
}

# EKS Clusters
data "aws_eks_cluster" "specific_eks" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "eks_clusters", [])
  ]))

  name = each.value
}

# EC2 Instances (by Name tag)
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

# VPC Endpoints (by endpoint ID)
data "aws_vpc_endpoint" "specific_endpoints" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "vpc_endpoints", [])
  ]))

  id = each.value
}
