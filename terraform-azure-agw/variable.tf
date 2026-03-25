variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "agw_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the AGW will be placed"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP for the AGW"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "The SKU tier of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "autoscale_min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 0
}

variable "autoscale_max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10
}

variable "backend_ips" {
  description = "List of backend IP addresses"
  type        = list(string)
}

variable "backend_port" {
  description = "Backend port"
  type        = number
  default     = 443
}

variable "backend_protocol" {
  description = "Backend protocol - Http or Https"
  type        = string
  default     = "Https"
}

variable "backend_request_timeout" {
  description = "Backend request timeout in seconds"
  type        = number
  default     = 60
}

variable "frontend_port" {
  description = "Frontend listener port"
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Listener protocol - Http or Https"
  type        = string
  default     = "Https"
}

variable "probe_path" {
  description = "Health probe path"
  type        = string
  default     = "/"
}

variable "probe_interval" {
  description = "Health probe interval in seconds"
  type        = number
  default     = 30
}

variable "probe_timeout" {
  description = "Health probe timeout in seconds"
  type        = number
  default     = 30
}

variable "probe_unhealthy_threshold" {
  description = "Health probe unhealthy threshold count"
  type        = number
  default     = 3
}

variable "probe_status_codes" {
  description = "Accepted health probe status codes"
  type        = list(string)
  default     = ["200-399"]
}

variable "ssl_certificate_data" {
  description = "Base64-encoded PFX certificate data"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password for the PFX SSL certificate"
  type        = string
  sensitive   = true
}

variable "trusted_root_certificate_data" {
  description = "Base64-encoded trusted root certificate (.crt) data"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostics"
  type        = string
}

variable "diag_storage_account_name" {
  description = "Name of the storage account for AGW diagnostic logs"
  type        = string
}

variable "diag_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default     = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
}

variable "law_retention_days" {
  description = "Log Analytics Workspace retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
