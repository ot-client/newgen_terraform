output "route_table_ids" {
  description = "Map of route table name to ID"
  value       = { for k, v in aws_route_table.rt : k => v.id }
}
