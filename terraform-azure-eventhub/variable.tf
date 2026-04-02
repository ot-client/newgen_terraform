variable "namespace_name" {
  description = "The name of the EventHub Namespace"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku" {
  description = "Pricing tier of the EventHub Namespace (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = "Throughput units for the EventHub Namespace (1-20 for Standard)"
  type        = number
  default     = 1

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 20
    error_message = "capacity must be between 1 and 20."
  }
}

variable "local_authentication_enabled" {
  description = "Enable local authentication (SAS) for the EventHub Namespace"
  type        = bool
  default     = true
}

variable "eventhub_name" {
  description = "Name of the EventHub (Kafka topic)"
  type        = string
}

variable "partition_count" {
  description = "Number of partitions for the EventHub (2-32)"
  type        = number
  default     = 2

  validation {
    condition     = var.partition_count >= 2 && var.partition_count <= 32
    error_message = "partition_count must be between 2 and 32."
  }
}

variable "message_retention" {
  description = "Message retention in days (1-7 for Standard)"
  type        = number
  default     = 1

  validation {
    condition     = var.message_retention >= 1 && var.message_retention <= 7
    error_message = "message_retention must be between 1 and 7."
  }
}

variable "subnet_id" {
  description = "Subnet ID for the private endpoint. Required when connectivity is Private"
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  type        = string
  default     = null
}

variable "private_service_connection_name" {
  description = "Name of the private service connection"
  type        = string
  default     = null
}

variable "is_manual_connection" {
  description = "Whether the private endpoint connection requires manual approval"
  type        = bool
  default     = false
}

variable "private_endpoint_subresource" {
  description = "Subresource name for the private endpoint (namespace for EventHub)"
  type        = string
  default     = "namespace"
}

variable "tags" {
  description = "Tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "public_access_network_enable" {
  type        = bool
}