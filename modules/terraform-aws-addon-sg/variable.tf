variable "security_groups" {
  description = "Map of security groups configuration"
  type = map(object({
    name             = string
    vpc_id           = optional(string)        # Required only for new SGs
    create_new_sg    = optional(bool, true)    # true = create new SG, false = use existing SG
    existing_sg_id   = optional(string)        # Required when create_new_sg = false
    rules = map(object({
      type        = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      source_sg_id = optional(string)
      description = optional(string)
    }))
    eni_ids = optional(map(string), {})
    
    # Service-specific targeting (replaces attach_to_services)
    service_attachments = optional(object({
      rds_clusters    = optional(list(string), [])  # List of RDS cluster identifiers
      rds_instances   = optional(list(string), [])  # List of RDS instance identifiers
      efs_filesystems = optional(list(string), [])  # List of EFS filesystem IDs
      redis_clusters  = optional(list(string), [])  # List of Redis cluster IDs
      eks_clusters    = optional(list(string), [])  # List of EKS cluster names
      ec2_instances   = optional(list(string), [])  # List of EC2 instance names/IDs
      vpc_endpoints   = optional(list(string), [])  # List of VPC endpoint IDs
    }), {})
    
    # Backward compatibility
    attach_to_services = optional(bool, false)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}