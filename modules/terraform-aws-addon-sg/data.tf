# EFS Mount Targets (specific filesystems by ID — must use fs-xxxx format)
data "aws_efs_mount_target" "specific_efs" {
  for_each = toset(flatten([
    for sg_key, sg_config in var.security_groups :
    lookup(lookup(sg_config, "service_attachments", {}), "efs_filesystems", [])
  ]))

  file_system_id = each.value
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
