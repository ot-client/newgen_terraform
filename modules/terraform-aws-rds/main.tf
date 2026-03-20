resource "aws_rds_cluster" "rds" {
  cluster_identifier     = var.cluster_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = var.master_password
  port                   = var.port
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  storage_encrypted      = var.storage_encrypted
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  tags = merge(
    {
      Name = var.cluster_identifier
    },
    local.common_tags
  )
}


resource "aws_rds_cluster_instance" "rds_instance" {
  count               = var.cluster_instance_count
  identifier          = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.rds.id
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  publicly_accessible = var.publicly_accessible
  tags = merge(
    {
      Name = "${var.cluster_identifier}-${count.index + 1}"
    },
    local.common_tags
  )
}
