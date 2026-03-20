# ── Naming ───────────────────────────────

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# ── Cluster Identity ─────────────────────────────────────────────
variable "replication_group_id" {
  type        = string
  description = "Explicit Redis cluster name (e.g. redisdev). Overrides base_name if set"
  default     = ""
}

# ── Engine ───────────────────────────────────────────────────────
variable "engine_version" {
  type        = string
  description = "Redis engine version (e.g. 7.1)"
}
variable "node_type" {
  type        = string
  description = "ElastiCache node type (e.g. cache.t3.medium)"
}
variable "port" {
  type        = number
  default     = 6379
  description = "Redis port"
}
variable "redis_family" {
  type        = string
  description = "Parameter group family (e.g. redis7)"
}

# ── Cluster ──────────────────────────────────────────────────────
variable "num_cache_clusters" {
  type        = number
  description = "Total nodes: 1 primary + N replicas. Min 2 for Multi-AZ"
}
variable "multi_az_enabled" {
  type        = bool
  description = "Enable Multi-AZ with automatic failover"
}

# ── Networking ───────────────────────────────────────────────────
variable "create_subnet_group" {
  type        = bool
  default     = true
  description = "Set true to create a new subnet group"
}
variable "subnet_group_name" {
  type        = string
  default     = ""
  description = "Name for the new or existing subnet group"
}
variable "existing_subnet_group_name" {
  type        = string
  default     = ""
  description = "Name of a pre-existing subnet group. If set, module skips creating one (Deprecated: use subnet_group_name + create_subnet_group = false instead)"
}
variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID — required only if create_default_security_group = true"
}
variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs — required only if existing_subnet_group_name is empty"
}

# ── Security Group ───────────────────────────────────────────────
variable "create_default_security_group" {
  type        = bool
  default     = false
  description = "Set true to create a new SG. Set false to use existing_security_group_ids"
}
variable "security_group_name" {
  type        = string
  default     = ""
  description = "Name for the new security group"
}
variable "existing_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Pre-existing security group IDs to attach"
}
variable "allowed_ingress_ports" {
  type        = list(number)
  default     = [6379]
  description = "Ports to allow inbound (used only if create_default_security_group = true)"
}
variable "allowed_ingress_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDRs to allow inbound (used only if create_default_security_group = true)"
}

# ── Parameter Group ──────────────────────────────────────────────
variable "parameter_group_name" {
  type        = string
  default     = ""
  description = "AWS default or custom parameter group name"
}
variable "parameter_group_enabled" {
  type        = bool
  default     = false
  description = "Set true to create a custom parameter group"
}
variable "parameter" {
  type        = list(object({ name = string, value = string }))
  default     = []
  description = "Custom Redis parameters (only if parameter_group_enabled = true)"
}

# ── Encryption ───────────────────────────────────────────────────
variable "at_rest_encryption_enabled" {
  type        = bool
  description = "Enable encryption at rest"
}
variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable encryption in transit (TLS)"
}
variable "transit_encryption_mode" {
  type        = string
  description = "required or preferred"
}
variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ARN. Leave empty for AWS owned key"
}

# ── Backup ───────────────────────────────────────────────────────
variable "snapshot_retention_limit" {
  type        = number
  description = "Snapshot retention in days. 0 = disabled"
}
variable "snapshot_window" {
  type        = string
  default     = "00:00-01:00"
  description = "Daily UTC backup window (ignored if retention = 0)"
}

# ── Maintenance ──────────────────────────────────────────────────
variable "maintenance_window" {
  type        = string
  description = "Weekly UTC maintenance window (e.g. sun:06:30-sun:07:30)"
}
variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Auto apply minor Redis version upgrades"
}
