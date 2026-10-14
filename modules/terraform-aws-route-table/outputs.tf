output "route_table_ids" {
  description = "Map of route table name => ID"
  value       = { for k, v in aws_route_table.rt : k => v.id }
}
