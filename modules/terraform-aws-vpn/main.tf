######################################
# Customer Gateway
######################################
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = var.bgp_asn
  ip_address = var.cgw_ip_address
  type       = "ipsec.1"

  tags = merge({ Name = var.cgw_name }, var.tags)
}

######################################
# Site-to-Site VPN Connection
######################################
resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  vpn_gateway_id      = var.vgw_id
  type                = "ipsec.1"
  static_routes_only  = true

  # Tunnel 1
  tunnel1_ike_versions                 = var.tunnel1_ike_versions
  tunnel1_phase1_encryption_algorithms = var.tunnel1_phase1_encryption_algorithms
  tunnel1_phase2_encryption_algorithms = var.tunnel1_phase2_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.tunnel1_phase1_integrity_algorithms
  tunnel1_phase2_integrity_algorithms  = var.tunnel1_phase2_integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = var.tunnel1_phase1_dh_group_numbers
  tunnel1_phase2_dh_group_numbers      = var.tunnel1_phase2_dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = var.tunnel1_phase1_lifetime_seconds
  tunnel1_phase2_lifetime_seconds      = var.tunnel1_phase2_lifetime_seconds
  tunnel1_dpd_timeout_seconds          = var.tunnel1_dpd_timeout_seconds
  tunnel1_dpd_timeout_action           = var.tunnel1_dpd_timeout_action
  tunnel1_startup_action               = var.tunnel1_startup_action

  # Tunnel 2 (same settings)
  tunnel2_ike_versions                 = var.tunnel2_ike_versions
  tunnel2_phase1_encryption_algorithms = var.tunnel2_phase1_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.tunnel2_phase2_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.tunnel2_phase1_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.tunnel2_phase2_integrity_algorithms
  tunnel2_phase1_dh_group_numbers      = var.tunnel2_phase1_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.tunnel2_phase2_dh_group_numbers
  tunnel2_phase1_lifetime_seconds      = var.tunnel2_phase1_lifetime_seconds
  tunnel2_phase2_lifetime_seconds      = var.tunnel2_phase2_lifetime_seconds
  tunnel2_dpd_timeout_seconds          = var.tunnel2_dpd_timeout_seconds
  tunnel2_dpd_timeout_action           = var.tunnel2_dpd_timeout_action
  tunnel2_startup_action               = var.tunnel2_startup_action

  tags = merge({ Name = var.vpn_name }, var.tags)
}

######################################
# Route Table Propagation (all RTs)
######################################
resource "aws_vpn_gateway_route_propagation" "rt_propagation" {
  for_each = toset(var.route_table_ids)

  vpn_gateway_id = var.vgw_id
  route_table_id = each.value
}
