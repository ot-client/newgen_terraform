variable "region" {
  type = string
}

variable "launch_templates" {
  description = "Map of launch template configurations"
  type = map(object({
    instance_type          = string
    metadata_http_endpoint = string
    metadata_http_tokens   = string
    metadata_hop_limit     = number
    volume_device_name     = string
    volume_size            = number
    delete_on_termination  = bool
    volume_type            = string
    encrypted              = bool
    throughput             = number
  }))
}

variable "tags" {
  description = "Common tags applied to all launch templates"
  type        = map(string)
  default     = {}
}
