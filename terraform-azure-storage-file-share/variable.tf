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
}

variable "account_replication_type" {
  description = "Redundancy: LRS for non-prod, GRS for prod."
  type        = string
}

variable "access_tier" {
  description = "Access tier: Hot or Cool."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
}

variable "share_retention_days" {
  description = "Soft-delete retention days for file shares."
  type        = number
}

variable "file_shares" {
  description = "Map of file shares: name => { quota_gb, access_tier }"
  type = map(object({
    quota_gb    = number
    access_tier = string
  }))
}

variable "tags" {
  description = "Tags to assign to resources."
  type        = map(string)
  default     = {}
}
