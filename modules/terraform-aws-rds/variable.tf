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

variable "db_subnet_group_name" {
  description = "Subnet group name for RDS"
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

variable "cluster_instance_count" {
  description = "Number of RDS instances in the cluster"
  type        = number
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible"
  type        = bool
}


# Security group
variable "name_sg" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
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

