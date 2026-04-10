# RDS Configuration
variable "engine" {
  description = "Database engine (aurora-postgresql)"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "cluster_identifier" {
  description = "RDS cluster identifier"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs attached to the RDS cluster"
  type        = list(string)
}

variable "port" {
  description = "Database port"
  type        = number
}

variable "master_username" {
  description = "Master DB username"
  type        = string
}

variable "master_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
}

variable "storage_encrypted" {
  description = "Enable storage encryption for the cluster"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "cluster_instance_count" {
  description = "Number of RDS instances in the cluster"
  type        = number
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible"
  type        = bool
}


variable "availability_zones" {
  description = "List of availability zones for the RDS cluster"
  type        = list(string)
  default     = []
}

variable "storage_type" {
  description = "Storage type for the RDS cluster (aurora, aurora-iopt1)"
  type        = string
  default     = "aurora"
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Retention period for Performance Insights in days (7 or 731)"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds (0 to disable, 1/5/10/15/30/60)"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "ARN of IAM role for Enhanced Monitoring"
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (instance, postgresql)"
  type        = list(string)
  default     = []
}

# Security group
variable "name_sg" {
  description = "Name of the security group"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Security group rules (optional)
variable "ingress_rule" {
  description = "Ingress rule configuration"
  type = object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    description = "Allow DB access"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/18"]
  }
}

variable "egress_rule" {
  description = "Egress rule configuration"
  type = object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

