variable "local_network_gateway_name" {
  description = "The name of the local network gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region."
  type        = string
}

variable "local_gateway_address" {
  description = "The IP address of the on-premises VPN device."
  type        = string
}

variable "local_address_space" {
  description = "The list of on-premises IP address ranges."
  type        = list(string)
}

variable "connection_name" {
  description = "The name of the virtual network gateway connection."
  type        = string
}

variable "virtual_network_gateway_id" {
  description = "The ID of the virtual network gateway."
  type        = string
}

variable "shared_key" {
  description = "The shared PKI key."
  type        = string
  sensitive   = true
}

variable "connection_mode" {
  description = "The connection mode (Default, InitiatorOnly, ResponderOnly)."
  type        = string
  default     = "Default"
}

variable "connection_protocol" {
  description = "The connection protocol (IKEv1, IKEv2)."
  type        = string
  default     = "IKEv2"
}

variable "dpd_timeout_seconds" {
  description = "Dead Peer Detection timeout."
  type        = number
  default     = 45
}

# IPsec Policy variables with defaults from User Requirement
variable "dh_group" {
  type    = string
  default = "DHGroup14"
}

variable "ike_encryption" {
  type    = string
  default = "AES256"
}

variable "ike_integrity" {
  type    = string
  default = "SHA256"
}

variable "ipsec_encryption" {
  type    = string
  default = "AES256"
}

variable "ipsec_integrity" {
  type    = string
  default = "SHA256"
}

variable "pfs_group" {
  type    = string
  default = "PFS2048"
}

variable "sa_datasize" {
  type    = number
  default = 102400000
}

variable "sa_lifetime" {
  type    = number
  default = 27000
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
