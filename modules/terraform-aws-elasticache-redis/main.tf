# ── Subnet Group ─────────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  count      = var.create_subnet_group && var.existing_subnet_group_name == "" ? 1 : 0
  name       = var.subnet_group_name != "" ? var.subnet_group_name : "${local.base_name}-subnetgrp"
  subnet_ids = var.subnet_ids
  tags = merge(
    { Name = var.subnet_group_name != "" ? var.subnet_group_name : "${local.base_name}-subnetgrp" },
    local.common_tags
  )
}
# ── Security Group ────────────────────────────────────────────────
resource "aws_security_group" "cache_sg" {
  count  = var.create_default_security_group ? 1 : 0
  name   = var.security_group_name != "" ? var.security_group_name : "${local.base_name}-sg"
  vpc_id = var.vpc_id
  tags = merge(
    { Name = var.security_group_name != "" ? var.security_group_name : "${local.base_name}-sg" },
    local.common_tags
  )
}
# ── Dynamic Ingress / Egress locals ──────────────────────────────
locals {
  cluster_name = var.replication_group_id != "" ? var.replication_group_id : local.base_name
  subnet_grp   = var.create_subnet_group ? aws_elasticache_subnet_group.cache_subnet_group[0].name : var.existing_subnet_group_name
  security_groups = var.create_default_security_group ? concat(
    [aws_security_group.cache_sg[0].id], var.existing_security_group_ids
  ) : var.existing_security_group_ids
  param_group = (
    var.parameter_group_enabled && var.parameter_group_name == ""
    ? aws_elasticache_parameter_group.cache_params[0].name
    : var.parameter_group_name
  )
  # One entry per (rule, cidr) pair — CIDR-based ingress
  # ingress_rules in tfvars drives this: each rule has port, cidr_blocks, source_sg_id, description
  ingress_cidr_rules = var.create_default_security_group ? flatten([
    for rule in var.ingress_rules : [
      for cidr in rule.cidr_blocks : {
        port        = rule.port
        cidr        = cidr
        description = rule.description
      }
    ] if length(rule.cidr_blocks) > 0
  ]) : []
  # One entry per rule where source_sg_id is set — SG-source ingress
  ingress_sg_rules = var.create_default_security_group ? [
    for rule in var.ingress_rules : {
      port         = rule.port
      source_sg_id = rule.source_sg_id
      description  = rule.description
    } if rule.source_sg_id != ""
  ] : []
  # Flattened egress rules — used only when egress_allow_all = false
  egress_cidr_rules = var.create_default_security_group && !var.egress_allow_all ? flatten([
    for rule in var.egress_rules : [
      for cidr in rule.cidr_blocks : {
        port        = rule.port
        cidr        = cidr
        description = rule.description
      }
    ]
  ]) : []
}
# Ingress: CIDR-based
# Port is driven by each ingress_rules entry in tfvars (e.g. port = 6379)
resource "aws_security_group_rule" "ingress_cidr" {
  count             = length(local.ingress_cidr_rules)
  type              = "ingress"
  from_port         = local.ingress_cidr_rules[count.index].port
  to_port           = local.ingress_cidr_rules[count.index].port
  protocol          = "tcp"
  cidr_blocks       = [local.ingress_cidr_rules[count.index].cidr]
  description       = local.ingress_cidr_rules[count.index].description
  security_group_id = aws_security_group.cache_sg[0].id
}
# Ingress: Source SG-based (EKS nodes, EC2, Lambda etc.)
# Port is driven by each ingress_rules entry in tfvars (e.g. port = 6379)
resource "aws_security_group_rule" "ingress_sg" {
  count                    = length(local.ingress_sg_rules)
  type                     = "ingress"
  from_port                = local.ingress_sg_rules[count.index].port
  to_port                  = local.ingress_sg_rules[count.index].port
  protocol                 = "tcp"
  source_security_group_id = local.ingress_sg_rules[count.index].source_sg_id
  description              = local.ingress_sg_rules[count.index].description
  security_group_id        = aws_security_group.cache_sg[0].id
}
# Egress: allow-all (default when egress_allow_all = true)
resource "aws_security_group_rule" "egress_all" {
  count             = var.create_default_security_group && var.egress_allow_all ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cache_sg[0].id
}
# Egress: custom rules (used when egress_allow_all = false)
# Port is driven by each egress_rules entry in tfvars
resource "aws_security_group_rule" "egress_custom" {
  count             = length(local.egress_cidr_rules)
  type              = "egress"
  from_port         = local.egress_cidr_rules[count.index].port
  to_port           = local.egress_cidr_rules[count.index].port
  protocol          = "tcp"
  cidr_blocks       = [local.egress_cidr_rules[count.index].cidr]
  description       = local.egress_cidr_rules[count.index].description
  security_group_id = aws_security_group.cache_sg[0].id
}
# ── Parameter Group ───────────────────────────────────────────────
resource "aws_elasticache_parameter_group" "cache_params" {
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
    { Name = "pg-${local.base_name}" },
    local.common_tags
  )
}
# ── Redis Replication Group ───────────────────────────────────────
resource "aws_elasticache_replication_group" "cluster" {
  replication_group_id       = local.cluster_name
  description                = "${local.cluster_name} Redis Replication Group"
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = var.port
  parameter_group_name       = local.param_group
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.multi_az_enabled
  multi_az_enabled           = var.multi_az_enabled
  subnet_group_name          = local.subnet_grp
  security_group_ids         = local.security_groups
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_enabled ? var.transit_encryption_mode : null
  kms_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_retention_limit > 0 ? var.snapshot_window : null
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  tags = merge(
    { Name = local.cluster_name },
    local.common_tags
  )
}
