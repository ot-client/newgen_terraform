variable "acr_name" {
  description = "The name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "sku" {
  description = "The SKU of the container registry. Possible values are Basic, Standard and Premium."
  type        = string
  default     = "Premium"
}

variable "admin_enabled" {
  description = "Whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the subnet where the Private Endpoint will be created"
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "The name of the Private Endpoint"
  type        = string
  default     = null
}
