resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = var.tags
}

resource "azurerm_storage_account" "diag" {
  name                     = var.diag_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  tags = var.tags
}

locals {
  backend_address_pool_name      = "${var.agw_name}-beap"
  frontend_port_name             = "${var.agw_name}-feport"
  frontend_ip_configuration_name = "${var.agw_name}-feip"
  http_setting_name              = "${var.agw_name}-be-htst"
  listener_name                  = "${var.agw_name}-httplSTN"
  request_routing_rule_name      = "${var.agw_name}-rqrt"
  probe_name                     = "${var.agw_name}-hp"
  ssl_cert_name                  = "${var.agw_name}-ssl-cert"
  trusted_root_cert_name         = "${var.agw_name}-trusted-root"
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

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  ssl_certificate {
    name     = local.ssl_cert_name
    data     = var.ssl_certificate_data
    password = var.ssl_certificate_password
  }

  trusted_root_certificate {
    name = local.trusted_root_cert_name
    data = var.trusted_root_certificate_data
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_ips
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = var.cookie_based_affinity
    port                                = var.backend_port
    protocol                            = var.backend_protocol
    request_timeout                     = var.backend_request_timeout
    probe_name                          = local.probe_name
    pick_host_name_from_backend_address = var.pick_host_name_from_backend_address
    trusted_root_certificate_names      = [local.trusted_root_cert_name]
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = var.listener_protocol
    ssl_certificate_name           = local.ssl_cert_name
  }

  url_path_map {
    name                               = "${var.agw_name}-upm"
    default_backend_address_pool_name  = local.backend_address_pool_name
    default_backend_http_settings_name = local.http_setting_name

    path_rule {
      name                       = var.url_path_rule_name
      paths                      = var.url_path_rules
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.http_setting_name
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = var.routing_rule_type
    http_listener_name         = local.listener_name
    backend_address_pool_name  = var.routing_rule_type == "Basic" ? local.backend_address_pool_name : null
    backend_http_settings_name = var.routing_rule_type == "Basic" ? local.http_setting_name : null
    url_path_map_name          = var.routing_rule_type == "PathBasedRouting" ? "${var.agw_name}-upm" : null
    priority                   = var.routing_rule_priority
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = var.backend_protocol
    path                                      = var.probe_path
    interval                                  = var.probe_interval
    timeout                                   = var.probe_timeout
    unhealthy_threshold                       = var.probe_unhealthy_threshold
    pick_host_name_from_backend_http_settings = var.probe_pick_host_name_from_backend
    host                                      = var.probe_pick_host_name_from_backend ? null : var.probe_host
    port                                      = var.backend_port

    match {
      status_code = var.probe_status_codes
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "agw" {
  name                       = "${var.agw_name}-diag"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = azurerm_storage_account.diag.id

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
