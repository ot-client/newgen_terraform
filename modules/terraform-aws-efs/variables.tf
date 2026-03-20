# ─── Naming ───────────────────────────────────────────────────────────────────

# variable "env" {
#   description = "Environment name (e.g. dev, prod)"
#   type        = string
# }

# variable "app" {
#   description = "Application name"
#   type        = string
# }

variable "owner" {
  description = "Owner tag value"
  type        = string
  default     = "opstree"
}

variable "tags" {
  description = "Additional common tags for all resources"
  type        = map(string)
  default     = {}
}

# variable "program" {
#   description = "Project/Program name"
#   type        = string
#   default     = ""
# }

# variable "efs_tags" {
#   description = "Tag for EFS specific resources"
#   type        = string
#   default     = ""
# }

# ─── Security Group ───────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a managed EFS security group"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name for the EFS security group"
  type        = string
  default     = "efs-sg"
}

variable "nfs_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach NFS port 2049"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_self_referencing_sg_rule" {
  description = "Add a self-referencing ingress rule on port 2049 (Nikita's pattern)"
  type        = bool
  default     = false
}

# Security group IDs to attach when NOT creating a managed SG
variable "external_security_group_ids" {
  description = "External security group IDs to attach to mount targets (used when create_security_group = false)"
  type        = list(string)
  default     = []
}

# ─── New EFS Configs ──────────────────────────────────────────────────────────

variable "efs_configs" {
  description = "Map of new EFS file system configurations"
  default     = {}
  type = map(object({
    performance_mode                = optional(string, "generalPurpose")
    throughput_mode                 = optional(string, "elastic")
    provisioned_throughput_in_mibps = optional(number)
    encrypted                       = optional(bool, true)
    kms_key_id                      = optional(string)
    automatic_backups               = optional(string, "ENABLED")
    mount_point                     = optional(string) # for user-data template

    lifecycle_policies = optional(list(object({
      transition_to_ia                    = optional(string)
      transition_to_archive               = optional(string)
      transition_to_primary_storage_class = optional(string)
    })), [])

    access_points = optional(map(object({
      path = string
      posix_user = optional(object({
        gid            = number
        uid            = number
        secondary_gids = optional(list(number))
      }))
      creation_info = optional(object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      }))
    })), {})

    mount_targets = optional(list(object({
      subnet_id       = string
      security_groups = list(string)
    })), [])

    tags = optional(map(string), {})
  }))
}

# ─── Existing EFS Volumes (Nikita's pattern) ──────────────────────────────────

variable "add_subnet_efs_network" {
  description = "Whether to add mount targets for existing EFS volumes"
  type        = bool
  default     = false
}

variable "additional_existing_efs_volumes" {
  description = "List of existing EFS volumes to attach to a subnet"
  default     = null
  type = list(object({
    file_system_id = string
    mount_point    = string
    subnet_id      = string
  }))
}
