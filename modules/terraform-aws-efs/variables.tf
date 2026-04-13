variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# ─── Security Group ───────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "security_group_description" {
  description = "Description for EFS security groups"
  type        = string
  default     = "EFS security group"
}

variable "security_groups" {
  description = "Map of SG name to ingress/egress rules"
  type = map(object({
    ingress_rules = list(object({
      port         = number
      cidr_blocks  = list(string)
      source_sg_id = string
      description  = string
    }))
    egress_allow_all = bool
    egress_rules = list(object({
      port        = number
      cidr_blocks = list(string)
      description = string
    }))
  }))
  default = {}
}

# ─── Subnet ID Resolution ─────────────────────────────────────────────────────

variable "subnet_ids" {
  description = "Map of subnet name to subnet ID for resolving mount target subnet names"
  type        = map(string)
  default     = {}
}

# ─── EFS Configs ──────────────────────────────────────────────────────────────

variable "efs_configs" {
  description = "Map of EFS file system configurations"
  type        = any
  default     = {}
}
