variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "subnets" {
  type = map(string) # map of subnet name => subnet id
}

variable "nsg_rules" {
  type = any
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    environment = "non-prod"
  }
}

variable "enable_flow_logs" {
  description = "Enable NSG Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_storage_account_id" {
  description = "Storage Account ID for NSG Flow Logs"
  type        = string
  default     = null
}

variable "flow_log_workspace_id" {
  description = "Log Analytics Workspace ID for NSG Flow Logs"
  type        = string
  default     = null
}

variable "flow_log_retention_days" {
  description = "Retention days for flow logs in storage account (30 for non-prod, 90 for prod)"
  type        = number
}

variable "flow_log_traffic_analytics_interval" {
  description = "Traffic Analytics processing interval in minutes (10 or 60)"
  type        = number
  default     = 60
  validation {
    condition     = contains([10, 60], var.flow_log_traffic_analytics_interval)
    error_message = "Traffic Analytics interval must be either 10 or 60 minutes."
  }
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher (default: NetworkWatcher_<region>)"
  type        = string
  default     = null
}

variable "network_watcher_resource_group" {
  description = "Resource group of Network Watcher (default: NetworkWatcherRG)"
  type        = string
  default     = "NetworkWatcherRG"
}

variable "vnet_id" {
  description = "VNet ID (deprecated - kept for backward compatibility)"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "VNet name (deprecated - kept for backward compatibility)"
  type        = string
  default     = null
}
