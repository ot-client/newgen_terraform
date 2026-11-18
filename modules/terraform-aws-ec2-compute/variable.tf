variable "ec2_instances" {
  type = map(object({
    ami_id                 = string
    instance_type          = string
    subnet_id              = string
    security_groups        = list(string)
    # Pre-resolved SG IDs from an external security-groups module via remote state.
    # When provided, these are used directly on the instance instead of the
    # internally-created aws_security_group.sg resources.
    security_group_ids     = optional(list(string), [])
    # Set to true when passing pre-resolved security_group_ids from remote state.
    # Avoids using length() on an unknown list which causes provider plan errors.
    use_external_sg_ids    = optional(bool, false)
    public_ip              = optional(bool, false)
    key_name               = string
    create_key             = optional(bool, true)
    root_block_device      = object({
      size                  = number
      type                  = string
      throughput            = number
      iops                  = number
      encrypted             = bool
      delete_on_termination = bool
      tags                  = optional(map(string), {})
    })
    additional_volumes     = list(object({
      device_name = string
      size        = number
      type        = string
      throughput  = number
      iops        = number
      encrypted   = bool
      tags        = optional(map(string), {})
    }))
    enable_eip             = bool
    source_dest_check      = bool
    termination_protection = bool
    iam_instance_profile   = optional(string)
    metadata_options       = optional(object({
      http_tokens = optional(string, "v1+v2")  # v1+v2 | IMDSv2 only
    }), {})
    tags                   = map(string)
  }))
}


variable "security_groups" {
  description = "List of SG names to create inside the module. Leave empty when using centralized security-groups module via remote state."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups"
  default     = ""
}

variable "route_table_ids" {
  type = list(string)
}

variable "security_group_ports" {
  description = "Ingress/egress rules applied to internally-created SGs. Leave empty when using centralized security-groups module."
  type = map(object({
    from_port     = number
    to_port       = number
    protocol      = string
    name_regex    = string
    cidr_blocks   = optional(list(string))
    source_sg_id  = optional(string)
    type          = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}