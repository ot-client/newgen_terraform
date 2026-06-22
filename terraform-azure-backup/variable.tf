variable "vault_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "vault_sku" {
  default = "Standard"
}

variable "cross_region_restore_enabled" {
  description = "Enable cross-region restore for Recovery Vault (requires GRS/GZRS storage)"
  type        = bool
  default     = false
}

variable "soft_delete_enabled" {
  description = "Enable soft delete for Recovery Vault"
  type        = bool
  default     = true
}

variable "storage_mode_type" {
  description = "Storage redundancy type: LocallyRedundant, GeoRedundant, ZoneRedundant"
  type        = string
  default     = "GeoRedundant"
}

variable "vm_policy_name" {}
variable "timezone" {
  default = "UTC"
}
variable "backup_time" {
  description = "Backup start time in HH:MM (24hr UTC), e.g. 05:00"
  default     = "05:00"
}
variable "retention_daily_count" {
  description = "Number of daily backups to retain (7 = 1 week)"
  default     = 7
}
variable "vm_ids" {
  description = "Map of vm_name => vm_resource_id to protect. Add/remove VMs here in tfvars."
  type        = map(string)
  default     = {}
}
variable "tags" {
  type    = map(string)
  default = {}
}

# Azure Site Recovery Variables
variable "enable_site_recovery" {
  description = "Enable Azure Site Recovery for disaster recovery"
  type        = bool
  default     = false
}

variable "target_location" {
  description = "Target Azure region for Site Recovery replication"
  type        = string
  default     = null
}

variable "target_resource_group_name" {
  description = "Target resource group name for replicated resources"
  type        = string
  default     = null
}

variable "replication_policy_name" {
  description = "Name of the replication policy for Site Recovery"
  type        = string
  default     = "replication-policy"
}

variable "recovery_point_retention_in_minutes" {
  description = "Recovery point retention in minutes (minimum 1440 = 24 hours)"
  type        = number
  default     = 1440
}

variable "application_consistent_snapshot_frequency_in_minutes" {
  description = "Application consistent snapshot frequency in minutes"
  type        = number
  default     = 240
}
