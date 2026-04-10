resource "aws_rds_cluster" "rds" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  port                    = var.port
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  storage_encrypted       = var.storage_encrypted
  storage_type            = var.storage_type
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  availability_zones      = var.availability_zones
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(
    { Name = var.cluster_identifier },
    local.common_tags
  )
}

resource "aws_rds_cluster_instance" "rds_instance" {
  count                                 = var.cluster_instance_count
  identifier                            = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier                    = aws_rds_cluster.rds.id
  instance_class                        = var.instance_class
  engine                                = var.engine
  engine_version                        = var.engine_version
  publicly_accessible                   = var.publicly_accessible
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn

  tags = merge(
    { Name = "${var.cluster_identifier}-${count.index + 1}" },
    local.common_tags
  )
}
