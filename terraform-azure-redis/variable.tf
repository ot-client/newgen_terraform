variable "redis_name" {
  description = "The name of the Redis cache"
  type        = string
}

variable "location" {
  description = "The location/region where the Redis cache is created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "capacity" {
  description = "The size of the Redis cache (1GB = 1)"
  type        = number
  default     = 1
}

variable "sku_name" {
  description = "The SKU of Redis (Basic as per client requirement)"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "family" {
  description = "A map of tags to assign to the resource"
  type        = string
}

variable "minimum_tls_version" {
  description = "A map of tags to assign to the resource"
  type        = string
}

variable "public_network_access_enabled" {
  description = "A map of tags to assign to the resource"
  type        = bool
}



# Private endpoint managed separately in private-endpoint module
# variable "virtual_network_id" {
#   description = "The ID of the virtual network for private endpoint"
#   type        = string
# }

# variable "enable_private_endpoint" {
#   description = "Whether to create a private endpoint for Redis"
#   type        = bool
#   default     = false
# }

# variable "subnet_id" {
#   description = "The ID of the subnet for private endpoint"
#   type        = string
#   default     = null
# }

# variable "private_dns_zone_name" {
#   description = "Name of private DNS zone"
#   type        = string
#   default     = "privatelink.redis.cache.windows.net"
# }

# variable "private_dns_zone_virtual_network_link_name" {
#   description = "Name of private DNS zone virtual network link"
#   type        = string
# }