variable "create_security_group" {
  description = "Whether to create a new security group or use existing one"
  type        = bool
  default     = true
}

variable "existing_security_group_id" {
  description = "Existing security group ID to use (if create_security_group is false)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "security_group_name" {
  description = "Name of the ALB security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "egress_allow_all" {
  description = "Allow all outbound traffic"
  type        = bool
  default     = true
}

variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "internal" {
  description = "true = internal, false = internet-facing"
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type (ipv4 or dualstack)"
  type        = string
  default     = "ipv4"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}



variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# ── Access Logs ──────────────────────────────────────────────
variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}

variable "access_logs_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = ""
}

variable "access_logs_enabled" {
  description = "Enable ALB access logs"
  type        = bool
  default     = false
}

# ── Listener ─────────────────────────────────────────────────
variable "listener_port" {
  description = "Listener port"
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "HTTPS"
}

variable "ssl_policy" {
  description = "SSL security policy"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN to forward traffic to"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
