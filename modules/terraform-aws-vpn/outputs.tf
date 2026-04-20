output "cgw_id" {
  description = "Customer Gateway ID"
  value       = aws_customer_gateway.cgw.id
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = aws_vpn_connection.vpn.id
}

output "tunnel1_address" {
  description = "Public IP of VPN tunnel 1"
  value       = aws_vpn_connection.vpn.tunnel1_address
}

output "tunnel2_address" {
  description = "Public IP of VPN tunnel 2"
  value       = aws_vpn_connection.vpn.tunnel2_address
}
