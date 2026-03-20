variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "Launch template name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"

}

variable "metadata_http_endpoint" {
  description = "Enable or disable instance metadata endpoint"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "IMDS token requirement (optional = v1+v2, required = only v2)"
  type        = string
  default     = "optional"
}

variable "metadata_hop_limit" {
  description = "Hop limit for metadata requests"
  type        = number
  default     = 2
}

variable "volume_device_name" {
  type        = string
  description = "EBS device name"
  default     = "/dev/xvda"
}

variable "volume_size" {
  type        = number
  description = "Volume size in GB"
  default     = 100
}

variable "delete_on_termination" {
  type        = bool
  description = "Delete volume on instance termination"
  default     = true
}

variable "volume_type" {
  type        = string
  description = "Volume type"
  default     = "gp3"
}

variable "encrypted" {
  type        = bool
  description = "Enable volume encryption"
  default     = true
}

variable "throughput" {
  type        = number
  description = "Throughput for gp3 volumes in MB/s"
  default     = 128
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)

  default = {}
}
