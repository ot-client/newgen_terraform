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
  description = "vnet name"
}

variable "subnet_id" {
  type        = string
  description = "subnet id."
}

variable "virtual_network_id" {
  description = "vnet id."
}

variable "db_username" {
  description = "PSQL DB USername"
  default     = "username"
}

variable "db_password" {
  description = "PSQL DB Password"
  default     = "P@ssw0rd"
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
  default     = ["Microsoft.Storage"]
}


variable "delegation_name" {
  description = "delegation_name"
  default     = "affs"
}

variable "service_delegation" {
  description = "service_delegation"
  default     = "Microsoft.DBforPostgreSQL/flexibleServers"
}

variable "action" {
  description = "action"
  default = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
  ]
}

variable "posgressversion" {
  description = ""
  default     = "12"
}

variable "storage_mb" {
  description = "strorage_mb"
  default     = 256000
}

variable "storage_tier" {
  description = "Storage tier for PostgreSQL Flexible Server (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80)"
  default     = "P10"
}

variable "sku_name" {
  description = "sku_name"
  default     = "GP_Standard_D4s_v3"
}

variable "backup_retention_days" {
  description = "backup_retention_days"
  default     = 7
}

variable "tags" {
  description = "Define resource tags"
}

variable "public_network_access_enabled" {
  description = "public_network_access_enabled"
  default     = "false"
}

variable "private_dns_zone_name" {
  description = "private_dns_zone_name"
}

variable "private_dns_zone_virtual_network_link_name" {
  description = "he name which should be used for this Private DNS Resolver Virtual Network Link"
}

# HA toggle: true = enable SameZone high availability
variable "high_availability_enabled" {
  description = "Enable High Availability for PostgreSQL Flexible Server"
  default     = false
}

# DR: geo-redundant backup stores backups in paired region (GRS)
variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backup for DR (GRS)"
  default     = false
}

# Maintenance window variables - client changes these in tfvars
# day_of_week: 0=Sunday, 1=Monday, 2=Tuesday ... 6=Saturday
variable "maintenance_window_day" {
  description = "Day of week for maintenance window (0=Sunday, 6=Saturday)"
  default     = 0
}

variable "maintenance_window_hour" {
  description = "Start hour (UTC) for maintenance window (0-23)"
  default     = 3
}

variable "maintenance_window_minute" {
  description = "Start minute for maintenance window (0-59)"
  default     = 0
}

# Diagnostic settings toggle
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for logs and metrics"
  default     = false
}

# Diagnostic log categories
variable "diagnostic_log_categories" {
  description = "List of log categories to enable for diagnostic settings"
  type        = list(string)
  default     = ["PostgreSQLLogs", "PostgreSQLFlexDatabaseXacts"]
}

#for all metrics 

variable "enable_all_metrics" {
  description = "Enable all available PostgreSQL Flexible Server metrics"
  type        = bool
  default     = false
}

# Log Analytics Workspace ID - fetched from AGW remote state in wrapper
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  default     = null
}

# Storage Account ID - fetched from AGW remote state in wrapper
variable "diagnostic_storage_account_id" {
  description = "Resource ID of the Storage Account for short-term logs (3 months / all logs)"
  default     = null
}

variable "audit_storage_account_id" {
  description = "Resource ID of the Storage Account for long-term audit logs (18 months / 8 years)"
  default     = null
}

variable "enable_alerts" {
  description = "Enable metric alerts for CPU, Memory and Storage"
  type        = bool
  default     = false
}

variable "alert_action_group_id" {
  description = "Action group ID to notify on alerts"
  type        = string
  default     = null
}

variable "enable_service_health_alert" {
  description = "Enable activity log alert for DB service up/down (start/stop events)"
  type        = bool
  default     = false
}

variable "activity_log_alert_location" {
  description = "Location for activity log alert. Azure only supports global, westeurope, northeurope, eastus2euap"
  type        = string
  default     = "global"
}

variable "alert_rules" {
  description = "Map of metric alert rules for PostgreSQL (CPU, Memory, Storage)"
  type = map(object({
    description = string
    metric_name = string
    aggregation = string
    threshold   = number
    severity    = number
    frequency   = string
    window_size = string
  }))
  default = {
    cpu = {
      description = "CPU utilization above threshold"
      metric_name = "cpu_percent"
      aggregation = "Average"
      threshold   = 80
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT15M"
    }
    memory = {
      description = "Memory utilization above threshold"
      metric_name = "memory_percent"
      aggregation = "Average"
      threshold   = 80
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT15M"
    }
    storage = {
      description = "Storage utilization above threshold"
      metric_name = "storage_percent"
      aggregation = "Average"
      threshold   = 80
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT15M"
    }
  }
}

variable "mode" {
  type = string
}

variable "db_parameters" {
  description = "PostgreSQL server configuration parameters"
  type        = map(string)
  default = {
    log_connections                = "on"
    log_disconnections             = "on"
    log_duration                   = "on"
    log_min_duration_statement     = "500"
    log_statement                  = "mod"
    shared_preload_libraries       = "pg_cron,pg_stat_statements,pgaudit"
    "pg_stat_statements.max"       = "2147483646"
    "pg_stat_statements.track"     = "top"
    "pg_stat_statements.track_utility" = "on"
    log_line_prefix                = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h "
    "azure.extensions"             = "pgaudit,amcheck"
    "pgaudit.log_client"           = "on"
  }
}