variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "The Azure region where the storage account should be created."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool."
  type        = string
  default     = "Hot"
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account"
  type        = string
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of public IP or IP ranges in CIDR Format that should be able to access the storage account."
  type        = list(string)
  default     = []
}

variable "network_rules_default_action" {
  description = "Network rules default action - Allow or Deny"
  type        = string
}

variable "network_rules_bypass" {
  description = "Network rules bypass list"
  type        = list(string)
}

variable "allowed_subnet_ids" {
  description = "A list of resource ids for subnets."
  type        = list(string)
  default     = []
}

variable "blob_versioning_enabled" {
  description = "Controls whether blob versioning is enabled."
  type        = bool
  default     = true
}

variable "containers" {
  description = "Map of containers to create and their access levels."
  type = map(object({
    container_access_type = string
  }))
  default = {
    "default" = {
      container_access_type = "private"
    }
  }
}

variable "blob_lifecycle_rules" {
  description = "Container wise blob retention policy"
  type = map(object({
    retention_days = number
  }))
  default = {}
}

variable "account_kind" {
  description = "Storage account kind. StorageV2 for payg, FileStorage for provisioned_v2."
  type        = string
  default     = "StorageV2"
}

variable "share_retention_days" {
  description = "Soft-delete retention days for file shares (1-365). Set to 0 to disable."
  type        = number
  default     = 0
}

variable "file_shares" {
  description = <<-EOT
    Map of file shares to create. Key is share name.

    billing_model:
      "payg"           - Standard StorageV2, billed per GB used + transactions
      "provisioned_v2" - Premium FileStorage, manual IOPS + Throughput via AzAPI

    Pay-As-You-Go (billing_model = "payg"):
      quota_gb    = any size (min 1 GiB)
      access_tier = Hot | Cool | TransactionOptimized
      provisioned_iops / provisioned_bandwidth_mibps = null

    Provisioned v2 (billing_model = "provisioned_v2"):
      quota_gb    = min 100 GiB
      access_tier = "Premium"
      provisioned_iops            = 3000-100000 (null = Azure auto-calculates)
      provisioned_bandwidth_mibps = 60-10240    (null = Azure auto-calculates)
  EOT
  type = map(object({
    billing_model               = optional(string, "payg")
    quota_gb                    = number
    access_tier                 = string
    provisioned_iops            = optional(number, null)
    provisioned_bandwidth_mibps = optional(number, null)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "diagnostic_settings_enabled" {
  description = "Enable diagnostic settings for the storage account."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostics to."
  type        = string
  default     = null
}

variable "archive_storage_account_id" {
  description = "The ID of the Storage Account to archive diagnostic logs to."
  type        = string
  default     = null
}

variable "log_retention_enabled" {
  description = "Whether retention policy is enabled for blob diagnostic logs."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain diagnostic logs in the archive storage account."
  type        = number
  default     = 90
}
