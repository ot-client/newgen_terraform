output "tgw_route_ids" {
  description = "Map of route table ID to the created TGW route ID"
  value       = { for k, v in aws_route.tgw_routes : k => v.id }
}
