######################################
# Customer Gateway
######################################
variable "cgw_name" {
  type = string
}

variable "bgp_asn" {
  type    = number
  default = 65000
}

variable "cgw_ip_address" {
  type        = string
  description = "Public IP address of the on-premises customer gateway device"
}

######################################
# VPN Connection
######################################
variable "vpn_name" {
  type = string
}

variable "vgw_id" {
  type        = string
  description = "ID of the Virtual Private Gateway"
}

######################################
# Tunnel 1 Options
######################################
variable "tunnel1_ike_versions" {
  type    = list(string)
  default = ["ikev1", "ikev2"]
}

variable "tunnel1_phase1_encryption_algorithms" {
  type    = list(string)
  default = ["AES256"]
}

variable "tunnel1_phase2_encryption_algorithms" {
  type    = list(string)
  default = ["AES256"]
}

variable "tunnel1_phase1_integrity_algorithms" {
  type    = list(string)
  default = ["SHA2-256"]
}

variable "tunnel1_phase2_integrity_algorithms" {
  type    = list(string)
  default = ["SHA2-256"]
}

variable "tunnel1_phase1_dh_group_numbers" {
  type    = list(number)
  default = [14]
}

variable "tunnel1_phase2_dh_group_numbers" {
  type    = list(number)
  default = [14]
}

variable "tunnel1_phase1_lifetime_seconds" {
  type    = number
  default = 28800
}

variable "tunnel1_phase2_lifetime_seconds" {
  type    = number
  default = 3600
}

variable "tunnel1_dpd_timeout_seconds" {
  type    = number
  default = 30
}

variable "tunnel1_dpd_timeout_action" {
  type    = string
  default = "restart"
}

variable "tunnel1_startup_action" {
  type    = string
  default = "start"
}

######################################
# Tunnel 2 Options
######################################
variable "tunnel2_ike_versions" {
  type    = list(string)
  default = ["ikev1", "ikev2"]
}

variable "tunnel2_phase1_encryption_algorithms" {
  type    = list(string)
  default = ["AES256"]
}

variable "tunnel2_phase2_encryption_algorithms" {
  type    = list(string)
  default = ["AES256"]
}

variable "tunnel2_phase1_integrity_algorithms" {
  type    = list(string)
  default = ["SHA2-256"]
}

variable "tunnel2_phase2_integrity_algorithms" {
  type    = list(string)
  default = ["SHA2-256"]
}

variable "tunnel2_phase1_dh_group_numbers" {
  type    = list(number)
  default = [14]
}

variable "tunnel2_phase2_dh_group_numbers" {
  type    = list(number)
  default = [14]
}

variable "tunnel2_phase1_lifetime_seconds" {
  type    = number
  default = 28800
}

variable "tunnel2_phase2_lifetime_seconds" {
  type    = number
  default = 3600
}

variable "tunnel2_dpd_timeout_seconds" {
  type    = number
  default = 30
}

variable "tunnel2_dpd_timeout_action" {
  type    = string
  default = "restart"
}

variable "tunnel2_startup_action" {
  type    = string
  default = "start"
}

######################################
# Route Propagation
######################################
variable "route_table_ids" {
  type        = list(string)
  description = "List of route table IDs to enable VGW route propagation"
  default     = []
}

######################################
# Tags
######################################
variable "tags" {
  type    = map(string)
  default = {}
}
