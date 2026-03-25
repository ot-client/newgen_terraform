variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "agw_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the AGW will be placed"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP for the AGW"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "The SKU tier of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "autoscale_min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 0
}

variable "autoscale_max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10
}

variable "backend_ips" {
  description = "List of backend IP addresses"
  type        = list(string)
  default     = ["10.0.0.1"] # Dummy IP as per requirements
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
