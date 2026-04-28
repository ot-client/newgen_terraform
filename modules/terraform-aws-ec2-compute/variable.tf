variable "ec2_instances" {
  type = map(object({
    ami_id                 = string
    instance_type          = string
    subnet_id              = string
    security_groups        = list(string)
    public_ip              = bool
    key_name               = string
    root_block_device      = object({
      size                  = number
      type                  = string
      throughput            = number
      iops                  = number
      encrypted             = bool
      delete_on_termination = bool
    })
    additional_volumes     = list(object({
      device_name = string
      size        = number
      type        = string
      throughput  = number
      iops        = number
      encrypted   = bool
    }))
    enable_eip             = bool
    source_dest_check      = bool
    termination_protection = bool
    iam_instance_profile   = optional(string)
    tags                   = map(string)
  }))
}


variable "security_groups" {
  description = "List of security groups to create"
  type        = list(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups"
}

variable "route_table_names" {
  type = list(string)
}

variable "firewall_instance_key" {
  description = "Key name of firewall EC2 instance"
  type        = string
}

variable "security_group_ports" {
  description = "Ingress port configuration mapped to SG name patterns"
  type = map(object({
    from_port     = number
    to_port       = number
    protocol      = string
    name_regex    = string
    cidr_blocks   = optional(list(string))
    source_sg_id  = optional(string)
    type          = string
  }))
}

variable "firewall_route_cidr" {
  description = "Destination CIDR block for firewall route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_algorithm" {
  description = "Algorithm for key pair generation"
  type        = string
  default     = "RSA"
}

variable "key_rsa_bits" {
  description = "RSA key size in bits"
  type        = number
  default     = 4096
}

variable "key_file_permission" {
  description = "File permission for the generated PEM key file"
  type        = string
  default     = "0400"
}

variable "tags" {
  type    = map(string)
  default = {}
}