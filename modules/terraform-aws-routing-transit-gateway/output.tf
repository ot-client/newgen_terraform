output "tgw_route_ids" {
  description = "Map of route key to created TGW route ID"
  value       = { for k, v in aws_route.tgw_routes : k => v.id }
}
