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

variable "public_ip_allocation_method" {
  description = "Public IP allocation method"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU"
  type        = string
  default     = "Standard"
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

# ==================================================
# BACKEND POOLS
# ==================================================

variable "backend_pools" {
  description = "Backend pools with backend HTTP settings and health probes"

  type = map(object({

    ips = list(string)

    port = number

    protocol = string

    request_timeout = number

    cookie_based_affinity = string

    pick_host_name_from_backend_address = bool

    probe = object({
      path = string

      interval = number

      timeout = number

      unhealthy_threshold = number

      status_codes = list(string)

      pick_host_name_from_backend_http_settings = bool

      host = optional(string)
    })
  }))
}

# ==================================================
# FRONTEND
# ==================================================

variable "frontend_port" {
  description = "Frontend listener port"
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "Https"
}

# ==================================================
# SSL
# ==================================================

variable "ssl_certificate_data" {
  description = "Base64 encoded PFX certificate data"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password for PFX certificate"
  type        = string
  sensitive   = true
}

variable "ssl_policy_type" {
  description = "SSL policy type"
  type        = string
  default     = "CustomV2"
}

variable "ssl_min_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1_2"
}

variable "ssl_cipher_suites" {
  description = "Allowed SSL cipher suites"
  type        = list(string)

  default = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  ]
}

# ==================================================
# ROUTING
# ==================================================

variable "routing_rule_type" {
  description = "Routing rule type"
  type        = string
  default     = "PathBasedRouting"
}

variable "routing_rule_priority" {
  description = "Routing rule priority"
  type        = number
  default     = 1
}

variable "url_path_rules" {
  description = "URL path rules mapped to backend pools"

  type = map(object({
    paths        = list(string)
    backend_pool = string
  }))
}

# ==================================================
# MULTIPLE FQDN / HOST RULES
# ==================================================

variable "host_rules" {
  description = "Optional multiple FQDN host rules. Leave empty when FQDN-based routing is not required."

  type = map(object({

    host_name = string

    routing_rule_type = string

    priority = number

    default_backend_pool = string

    url_path_rules = map(object({
      paths        = list(string)
      backend_pool = string
    }))
  }))

  default = {}
}



# ==================================================
# GATEWAY
# ==================================================

variable "gateway_ip_configuration_name" {
  description = "Gateway IP configuration name"
  type        = string
  default     = "appGatewayIpConfig"
}

# ==================================================
# DIAGNOSTICS
# ==================================================

variable "law_name" {
  description = "Log Analytics Workspace name"
  type        = string
}

variable "law_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "law_retention_days" {
  description = "Log Analytics retention"
  type        = number
  default     = 30
}

variable "diag_storage_account_id" {
  description = "Storage account ID for diagnostics"
  type        = string
}

variable "diag_metric_category" {
  description = "Diagnostic metric category"
  type        = string
  default     = "AllMetrics"
}

variable "diag_log_categories" {
  description = "Diagnostic log categories"
  type        = list(string)

  default = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog"
  ]
}

# ==================================================
# TAGS
# ==================================================

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}