variable "storage_account_name" {
  description = "Name of the storage account. Convention: <clientcode>fileshare<env>"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "account_tier" {
  description = "Performance tier: Standard or Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Redundancy: LRS for non-prod, GRS for prod."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Account-level access tier: Hot or Cool."
  type        = string
  default     = "Hot"
}

variable "public_network_access_enabled" {
  description = "Disable public network access."
  type        = bool
  default     = false
}

variable "blob_versioning_enabled" {
  description = "Enable versioning for blobs."
  type        = bool
  default     = true
}

variable "share_retention_days" {
  description = "Soft-delete retention days for file shares."
  type        = number
  default     = 7
}

variable "file_shares" {
  description = "Map of file shares to create: name => { quota_gb, access_tier }"
  type = map(object({
    quota_gb    = number
    access_tier = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to assign to resources."
  type        = map(string)
  default     = {}
}
