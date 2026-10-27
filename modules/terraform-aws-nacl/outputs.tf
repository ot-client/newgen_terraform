output "nacl_ids" {
  description = "Map of NACL name to ID"
  value       = { for k, v in aws_network_acl.nacls : k => v.id }
}
