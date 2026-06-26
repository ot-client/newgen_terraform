variable "workspace_name" {
  description = "The name of the Log Analytics Workspace."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where the workspace should be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Log Analytics Workspace. Possible values: PerGB2018, Free, CapacityReservation."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "The workspace data retention in days. Range: 30 to 730."
  type        = number
  default     = 30
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
