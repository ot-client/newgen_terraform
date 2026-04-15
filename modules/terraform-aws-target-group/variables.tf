variable "name" {
  description = "Name of the target group"
  type        = string
}

variable "protocol" {
  description = "Protocol for the target group (HTTP, HTTPS)"
  type        = string
}

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "ip_address_type" {
  description = "IP address type for the target group (ipv4 or ipv6)"
  type        = string
  default     = "ipv4"
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "protocol_version" {
  description = "Protocol version (HTTP1, HTTP2, GRPC)"
  type        = string
  default     = "HTTP1"
}

variable "health_check_protocol" {
  description = "Protocol for health checks (HTTP or HTTPS)"
  type        = string
  default     = "HTTPS"
}

variable "health_check_port" {
  description = "Port for health checks (traffic-port or a specific port number)"
  type        = string
  default     = "traffic-port"
}

variable "health_check_path" {
  description = "Destination path for health checks"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Interval (seconds) between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout (seconds) for a health check response"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks before marking healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking unhealthy"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP response codes to use when checking for a healthy response"
  type        = string
  default     = "200"
}

variable "stickiness_enabled" {
  description = "Enable stickiness for the target group"
  type        = bool
  default     = true
}

variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie or app_cookie)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_duration" {
  description = "Duration (seconds) for stickiness cookie"
  type        = number
  default     = 1800
}

variable "tags" {
  description = "Tags to apply to the target group"
  type        = map(string)
  default     = {}
}