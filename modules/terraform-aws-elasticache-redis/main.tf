# ── Subnet Group (only if create_subnet_group is true) ─────────────
resource "aws_elasticache_subnet_group" "this" {
  count      = var.create_subnet_group && var.existing_subnet_group_name == "" ? 1 : 0
  name       = var.subnet_group_name != "" ? var.subnet_group_name : "${local.base_name}-subnetgrp"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name = var.subnet_group_name != "" ? var.subnet_group_name : "${local.base_name}-subnetgrp"
    },
    local.common_tags
  )
}

# ── Security Group (only if create_default_security_group = true) ──
resource "aws_security_group" "this" {
  count       = var.create_default_security_group ? 1 : 0
  name        = var.security_group_name != "" ? var.security_group_name : null
  name_prefix = var.security_group_name == "" ? "${local.base_name}-sg" : null
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = var.security_group_name != "" ? var.security_group_name : "${local.base_name}-sg"
    },
    local.common_tags
  )
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create_default_security_group ? length(var.allowed_ingress_ports) * length(var.allowed_ingress_cidr_blocks) : 0
  type              = "ingress"
  from_port         = var.allowed_ingress_ports[floor(count.index / length(var.allowed_ingress_cidr_blocks))]
  to_port           = var.allowed_ingress_ports[floor(count.index / length(var.allowed_ingress_cidr_blocks))]
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ingress_cidr_blocks[count.index % length(var.allowed_ingress_cidr_blocks)]]
  security_group_id = aws_security_group.this[0].id
}

resource "aws_security_group_rule" "egress" {
  count             = var.create_default_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this[0].id
}

# ── Parameter Group (only if custom PG needed) ────────────────────
resource "aws_elasticache_parameter_group" "this" {
  count  = var.parameter_group_enabled && var.parameter_group_name == "" ? 1 : 0
  name   = "pg-${local.base_name}"
  family = var.redis_family

  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    {
      Name = "pg-${local.base_name}"
    },
    local.common_tags
  )
}

# ── Redis Replication Group ───────────────────────────────────────
locals {
  cluster_name    = var.replication_group_id != "" ? var.replication_group_id : local.base_name
  subnet_grp      = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : var.existing_subnet_group_name
  security_groups = var.create_default_security_group ? concat([aws_security_group.this[0].id], var.existing_security_group_ids) : var.existing_security_group_ids
  param_group     = var.parameter_group_enabled && var.parameter_group_name == "" ? aws_elasticache_parameter_group.this[0].name : var.parameter_group_name
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.cluster_name
  description          = "${local.cluster_name} Redis Replication Group"

  # Engine
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = local.param_group

  # HA
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.multi_az_enabled
  multi_az_enabled           = var.multi_az_enabled

  # Networking
  subnet_group_name  = local.subnet_grp
  security_group_ids = local.security_groups

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_enabled ? var.transit_encryption_mode : null
  kms_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null

  # Backup
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_retention_limit > 0 ? var.snapshot_window : null

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(
    {
      Name = local.cluster_name
    },
    local.common_tags
  )
}
