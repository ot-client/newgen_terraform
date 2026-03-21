variable "name" {
  description = "Prefix of the resource name."
}

variable "location" {
  description = "Location of the resource."
}

variable "postgres_zones" {
  description = "number of zone configuration for postgres."
}

variable "resource_group_name" {
  default     = ""
  description = "resource_group_name."
}

variable "virtual_network_name" {
  description =  "vnet name"
}

variable "subnet_id" {
  type = string
  description = "subnet id."
}

variable "virtual_network_id" {
  description = "vnet id."
}

variable "db_username" {
  description = "PSQL DB USername"
  default = "username"
}

variable "db_password" {
  description = "PSQL DB Password"
  default = "P@ssw0rd"
}

variable "security_rule" {
  description = "Security rule configuration"
  default = {
    name                       = "postgress-sec"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

variable "service_endpoints" {
  description = "service endpoint"
  default = ["Microsoft.Storage"]
}


variable "delegation_name" {
  description = "delegation_name"
  default = "affs"
}

variable "service_delegation" {
  description = "service_delegation"
  default = "Microsoft.DBforPostgreSQL/flexibleServers"
}

variable "action" {
  description = "action"
  default = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
}

variable "posgressversion" {
  description = ""
  default = "12"
}

variable "storage_mb" {
  description = "strorage_mb"
  default = 256000
}

variable "sku_name" {
  description = "sku_name"
  default = "GP_Standard_D4s_v3"
}

variable "backup_retention_days" {
  description = "backup_retention_days"
  default = 7
}

variable "tags" {
  description = "Define resource tags"
}

variable "public_network_access_enabled" {
  description = "public_network_access_enabled"
  default = "false"
}

variable "private_dns_zone_name" {
  description = "private_dns_zone_name"
}

variable "private_dns_zone_virtual_network_link_name" {
  description = "he name which should be used for this Private DNS Resolver Virtual Network Link"

}