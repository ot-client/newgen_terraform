variable "name" {
  description = "Name for the firewall EC2 instance."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the firewall EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the firewall EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the firewall EC2 instance will be launched."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the firewall EC2 instance."
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether to associate an auto-assigned public IP on launch."
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name to attach to the firewall EC2 instance."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Key pair name to use or create for the firewall EC2 instance."
  type        = string
}

variable "create_key_pair" {
  description = "Whether to generate and create a new AWS key pair."
  type        = bool
  default     = true
}

variable "private_key_algorithm" {
  description = "Algorithm for generated private key."
  type        = string
  default     = "RSA"
}

variable "private_key_rsa_bits" {
  description = "RSA key size when private_key_algorithm is RSA."
  type        = number
  default     = 4096
}

variable "private_key_output_path" {
  description = "Path where the generated private key PEM file will be written. Leave empty to skip local PEM output."
  type        = string
  default     = ""
}

variable "root_block_device" {
  description = "Root block device configuration."
  type = object({
    size                  = number
    type                  = string
    throughput            = number
    iops                  = number
    encrypted             = bool
    delete_on_termination = bool
  })
}

variable "additional_volumes" {
  description = "Additional EBS volumes to create and attach to the firewall EC2 instance."
  type = list(object({
    device_name = string
    size        = number
    type        = string
    throughput  = number
    iops        = number
    encrypted   = bool
  }))
  default = []
}

variable "create_new_eip" {
  description = "Whether to allocate and associate a new EIP with the firewall EC2 instance."
  type        = bool
  default     = true
}

variable "existing_eip_allocation_id" {
  description = "Existing EIP allocation ID to associate with the firewall EC2 instance. Leave empty to skip existing EIP association."
  type        = string
  default     = ""
}

variable "termination_protection" {
  description = "Whether API termination protection is enabled."
  type        = bool
  default     = false
}

variable "source_dest_check" {
  description = "Whether source/destination checking is enabled. Firewalls normally set this to false."
  type        = bool
  default     = false
}

variable "create_route_table_entries" {
  description = "Whether to add route-table entries that target the firewall primary ENI."
  type        = bool
  default     = false
}

variable "route_table_ids" {
  description = "Route table IDs where firewall routes will be created."
  type        = list(string)
  default     = []
}

variable "route_destination_cidr_blocks" {
  description = "Destination CIDR blocks for routes that should target the firewall primary ENI."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "user_data" {
  description = "Optional user data for firewall bootstrap."
  type        = string
  default     = null
}

variable "metadata_options" {
  description = "Instance metadata service options."
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}
