resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention_days

  tags = var.tags
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = var.tags
}

locals {
  frontend_port_name             = "${var.agw_name}-feport"
  frontend_ip_configuration_name = "${var.agw_name}-feip"
  listener_name                  = "${var.agw_name}-httplSTN"
  request_routing_rule_name      = "${var.agw_name}-rqrt"
  ssl_cert_name                  = "${var.agw_name}-ssl-cert"
}

resource "azurerm_application_gateway" "main" {
  name                = var.agw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }

  # --------------------------------------------------
  # Gateway subnet
  # --------------------------------------------------
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  # --------------------------------------------------
  # Frontend
  # --------------------------------------------------
  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  # --------------------------------------------------
  # SSL Policy
  # AGW level
  # --------------------------------------------------
  ssl_policy {
    policy_type          = var.ssl_policy_type
    min_protocol_version = var.ssl_min_protocol_version
    cipher_suites        = var.ssl_cipher_suites
  }

  # --------------------------------------------------
  # SSL Certificate
  # AGW level
  # --------------------------------------------------
  ssl_certificate {
    name     = local.ssl_cert_name
    data     = var.ssl_certificate_data
    password = var.ssl_certificate_password
  }

  # --------------------------------------------------
  # Backend Address Pools
  # Existing logic - unchanged
  # --------------------------------------------------
  dynamic "backend_address_pool" {
    for_each = var.backend_pools

    content {
      name         = "${var.agw_name}-${backend_address_pool.key}-pool"
      ip_addresses = backend_address_pool.value.ips
    }
  }

  # --------------------------------------------------
  # Backend HTTP Settings
  # Existing logic - unchanged
  # --------------------------------------------------
  dynamic "backend_http_settings" {
    for_each = var.backend_pools

    content {
      name                                = "${var.agw_name}-${backend_http_settings.key}-http"
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address

      probe_name = "${var.agw_name}-${backend_http_settings.key}-probe"

      trusted_root_certificate_names = []
    }
  }

  # ==================================================
  # NORMAL SINGLE-HOST LISTENER
  # Created when host_rules is empty
  # Existing behaviour preserved
  # ==================================================

  dynamic "http_listener" {
    for_each = length(var.host_rules) == 0 ? [1] : []

    content {
      name                           = local.listener_name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = var.listener_protocol
      ssl_certificate_name           = local.ssl_cert_name
    }
  }

  # ==================================================
  # MULTIPLE FQDN LISTENERS
  # One listener per hostname
  # ==================================================

  dynamic "http_listener" {
    for_each = var.host_rules

    content {
      name                           = "${var.agw_name}-${http_listener.key}-listener"
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = var.listener_protocol
      ssl_certificate_name           = local.ssl_cert_name

      host_names = [
        http_listener.value.host_name
      ]
    }
  }

  # ==================================================
  # NORMAL SINGLE-HOST PATH MAP
  # Existing url_path_rules logic - unchanged
  # ==================================================

  dynamic "url_path_map" {
    for_each = length(var.host_rules) == 0 && var.routing_rule_type == "PathBasedRouting" ? [1] : []

    content {
      name = "${var.agw_name}-upm"

      default_backend_address_pool_name = "${var.agw_name}-${keys(var.backend_pools)[0]}-pool"

      default_backend_http_settings_name = "${var.agw_name}-${keys(var.backend_pools)[0]}-http"

      dynamic "path_rule" {
        for_each = var.url_path_rules

        content {
          name  = path_rule.key
          paths = path_rule.value.paths

          backend_address_pool_name = "${var.agw_name}-${path_rule.value.backend_pool}-pool"

          backend_http_settings_name = "${var.agw_name}-${path_rule.value.backend_pool}-http"
        }
      }
    }
  }

  # ==================================================
  # FQDN PATH MAPS
  # One path map per hostname
  # ==================================================

  dynamic "url_path_map" {
    for_each = var.host_rules

    content {
      name = "${var.agw_name}-${url_path_map.key}-upm"

      default_backend_address_pool_name = "${var.agw_name}-${url_path_map.value.default_backend_pool}-pool"

      default_backend_http_settings_name = "${var.agw_name}-${url_path_map.value.default_backend_pool}-http"

      dynamic "path_rule" {
        for_each = var.host_rules[url_path_map.key].url_path_rules

        content {
          name  = path_rule.key
          paths = path_rule.value.paths

          backend_address_pool_name = "${var.agw_name}-${path_rule.value.backend_pool}-pool"

          backend_http_settings_name = "${var.agw_name}-${path_rule.value.backend_pool}-http"
        }
      }
    }
  }

  # ==================================================
  # NORMAL SINGLE-HOST REQUEST ROUTING RULE
  # ==================================================

  dynamic "request_routing_rule" {
    for_each = length(var.host_rules) == 0 ? [1] : []

    content {
      name               = local.request_routing_rule_name
      rule_type          = var.routing_rule_type
      http_listener_name = local.listener_name

      url_path_map_name = var.routing_rule_type == "PathBasedRouting" ? "${var.agw_name}-upm" : null

      backend_address_pool_name = var.routing_rule_type == "Basic" ? "${var.agw_name}-${keys(var.backend_pools)[0]}-pool" : null

      backend_http_settings_name = var.routing_rule_type == "Basic" ? "${var.agw_name}-${keys(var.backend_pools)[0]}-http" : null

      priority = var.routing_rule_priority
    }
  }

  # ==================================================
  # FQDN REQUEST ROUTING RULES
  # ==================================================

  dynamic "request_routing_rule" {
    for_each = var.host_rules

    content {
      name               = "${var.agw_name}-${request_routing_rule.key}-rqrt"
      rule_type          = request_routing_rule.value.routing_rule_type
      http_listener_name = "${var.agw_name}-${request_routing_rule.key}-listener"

      url_path_map_name = request_routing_rule.value.routing_rule_type == "PathBasedRouting" ? "${var.agw_name}-${request_routing_rule.key}-upm" : null

      backend_address_pool_name = request_routing_rule.value.routing_rule_type == "Basic" ? "${var.agw_name}-${request_routing_rule.value.default_backend_pool}-pool" : null

      backend_http_settings_name = request_routing_rule.value.routing_rule_type == "Basic" ? "${var.agw_name}-${request_routing_rule.value.default_backend_pool}-http" : null

      priority = request_routing_rule.value.priority
    }
  }

  # ==================================================
  # Health Probes
  # Existing logic - unchanged
  # ==================================================

  dynamic "probe" {
    for_each = var.backend_pools

    content {
      name                  = "${var.agw_name}-${probe.key}-probe"
      protocol              = probe.value.protocol
      path                  = probe.value.probe.path
      interval              = probe.value.probe.interval
      timeout               = probe.value.probe.timeout
      unhealthy_threshold   = probe.value.probe.unhealthy_threshold

      pick_host_name_from_backend_http_settings = probe.value.probe.pick_host_name_from_backend_http_settings

      host = probe.value.probe.pick_host_name_from_backend_http_settings ? null : probe.value.probe.host

      port = probe.value.port

      match {
        status_code = probe.value.probe.status_codes
      }
    }
  }

  tags = var.tags
}

# ==================================================
# Diagnostics
# Existing logic - unchanged
# ==================================================

resource "azurerm_monitor_diagnostic_setting" "agw" {
  name                       = "${var.agw_name}-diag"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  storage_account_id         = var.diag_storage_account_id

  dynamic "enabled_log" {
    for_each = var.diag_log_categories

    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = var.diag_metric_category
  }
}