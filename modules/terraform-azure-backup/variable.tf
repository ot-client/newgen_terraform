variable "vault_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "vault_sku" {
  default = "Standard"
}
variable "storage_mode_type" {
  description = "Storage replication type. Supported: GeoRedundant, LocallyRedundant, ZoneRedundant."
  default     = "GeoRedundant"
}
variable "cross_region_restore_enabled" {
  description = "Enable cross-region restore. Requires storage_mode_type = GeoRedundant."
  default     = false
}
variable "vm_policy_name" {}
variable "policy_type" {
  description = "Backup policy type. Use V2 for enhanced policies such as hourly backups."
  default     = "V1"
}
variable "consistency_type" {
  description = "Backup consistency type."
  default     = null
}
variable "timezone" {
  default = "UTC"
}
variable "backup_frequency" {
  description = "Backup frequency. Supported values are Hourly, Daily, and Weekly."
  default     = "Daily"
}
variable "backup_time" {
  description = "Backup start time in HH:MM, interpreted in the selected timezone."
  default     = "05:00"
}
variable "backup_hour_interval" {
  description = "Interval in hours for hourly backup policies. Supported values are 4, 6, 8, and 12."
  default     = null
}
variable "backup_hour_duration" {
  description = "Hourly backup window duration in hours."
  default     = null
}
variable "backup_weekdays" {
  description = "Weekdays to run backups when backup_frequency is Weekly."
  type        = list(string)
  default     = []
}
variable "instant_restore_retention_days" {
  description = "Number of days to retain instant recovery snapshots."
  default     = null
}
variable "instant_restore_resource_group_prefix" {
  description = "Prefix for the instant restore resource group."
  default     = null
}
variable "instant_restore_resource_group_suffix" {
  description = "Suffix for the instant restore resource group."
  default     = null
}
variable "retention_daily_count" {
  description = "Number of daily backups to retain (7 = 1 week)"
  default     = 7
}
variable "retention_weekly_count" {
  description = "Number of weekly backup points to retain."
  default     = null
}
variable "retention_weekly_weekdays" {
  description = "Weekdays to retain weekly backup points."
  type        = list(string)
  default     = []
}
variable "retention_monthly_count" {
  description = "Number of monthly backup points to retain."
  default     = null
}
variable "retention_monthly_weekdays" {
  description = "Weekdays to retain monthly backup points."
  type        = list(string)
  default     = []
}
variable "retention_monthly_weeks" {
  description = "Weeks of the month to retain monthly backup points."
  type        = list(string)
  default     = []
}
variable "retention_monthly_days" {
  description = "Days of the month to retain monthly backup points."
  type        = list(number)
  default     = []
}
variable "retention_monthly_include_last_days" {
  description = "Include the last day of the month for monthly retention."
  default     = false
}
variable "retention_yearly_count" {
  description = "Number of yearly backup points to retain."
  default     = null
}
variable "retention_yearly_months" {
  description = "Months to retain yearly backup points."
  type        = list(string)
  default     = []
}
variable "retention_yearly_weekdays" {
  description = "Weekdays to retain yearly backup points."
  type        = list(string)
  default     = []
}
variable "retention_yearly_weeks" {
  description = "Weeks of the month to retain yearly backup points."
  type        = list(string)
  default     = []
}
variable "retention_yearly_days" {
  description = "Days of the month to retain yearly backup points."
  type        = list(number)
  default     = []
}
variable "retention_yearly_include_last_days" {
  description = "Include the last day of the month for yearly retention."
  default     = false
}
variable "tiering_policy_archived_restore_point_mode" {
  description = "Tiering mode for archived restore points."
  default     = null
}
variable "tiering_policy_archived_restore_point_duration" {
  description = "Tiering duration for archived restore points."
  default     = null
}
variable "tiering_policy_archived_restore_point_duration_type" {
  description = "Tiering duration type for archived restore points."
  default     = null
}
# -----------------------------------------------------------------------
# PROD BACKUP POLICY
# -----------------------------------------------------------------------
variable "prod_policy_name" {
  description = "Name for the Prod VM backup policy. Set to null to skip creation."
  default     = null
}
variable "prod_timezone" {
  default = "UTC"
}
variable "prod_backup_time" {
  default = "05:00"
}
variable "prod_retention_daily_count" {
  default = 30
}
variable "prod_retention_weekly_count" {
  default = null
}
variable "prod_retention_weekly_weekdays" {
  type    = list(string)
  default = []
}
variable "prod_retention_monthly_count" {
  default = null
}
variable "prod_retention_monthly_weekdays" {
  type    = list(string)
  default = []
}
variable "prod_retention_monthly_weeks" {
  type    = list(string)
  default = []
}
variable "prod_retention_monthly_days" {
  type    = list(number)
  default = []
}
variable "prod_retention_monthly_include_last_days" {
  default = false
}
variable "prod_retention_yearly_count" {
  default = null
}
variable "prod_retention_yearly_months" {
  type    = list(string)
  default = []
}
variable "prod_retention_yearly_weekdays" {
  type    = list(string)
  default = []
}
variable "prod_retention_yearly_weeks" {
  type    = list(string)
  default = []
}
variable "prod_retention_yearly_days" {
  type    = list(number)
  default = []
}
variable "prod_retention_yearly_include_last_days" {
  default = false
}

# -----------------------------------------------------------------------
# AZURE SITE RECOVERY
# -----------------------------------------------------------------------
variable "enable_site_recovery" {
  description = "Enable Azure Site Recovery resources."
  default     = false
}
variable "target_location" {
  description = "Target region for Site Recovery replication."
  default     = null
}
variable "target_resource_group_name" {
  description = "Resource group in the target region for Site Recovery."
  default     = null
}
variable "replication_policy_name" {
  description = "Name of the Site Recovery replication policy."
  default     = null
}
variable "recovery_point_retention_in_minutes" {
  description = "Recovery point retention window in minutes."
  default     = 1440
}
variable "application_consistent_snapshot_frequency_in_minutes" {
  description = "App-consistent snapshot frequency in minutes."
  default     = 240
}

variable "vm_ids" {
  description = "Map of vm_name => vm_resource_id to protect. Add/remove VMs here in tfvars."
  type        = map(string)
  default     = {}
}

variable "diag_storage_account_id" {
  description = "Resource ID of the existing blob storage account for diagnostics"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}


#new line added 
variable "backup_policy_selection" {
  description = "Select backup policy for VM"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.backup_policy_selection)
    error_message = "Allowed values are dev or prod."
  }
}