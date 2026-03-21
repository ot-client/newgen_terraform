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

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the storage account."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "The ID of the subnet from which private IP addresses will be allocated for this Private Endpoint."
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "The name of the Private Endpoint."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
