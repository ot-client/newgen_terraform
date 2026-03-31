############################################################
# Security Group
############################################################

resource "aws_security_group" "rds_sg" {
  name        = var.name_sg
  description = "Security Group for RDS ${var.cluster_identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = var.name_sg },
    local.common_tags
  )

  lifecycle {
    ignore_changes = [egress]
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  description       = var.ingress_rule.description
  from_port         = var.ingress_rule.from_port
  to_port           = var.ingress_rule.to_port
  protocol          = var.ingress_rule.protocol
  cidr_blocks       = var.ingress_rule.cidr_blocks
  security_group_id = aws_security_group.rds_sg.id
}

############################################################
# RDS Cluster
############################################################

resource "aws_rds_cluster" "rds" {
  cluster_identifier     = var.cluster_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = var.master_password
  port                   = var.port
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = concat([aws_security_group.rds_sg.id], var.vpc_security_group_ids)
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
