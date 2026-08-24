# Primary output — consumed by all services via terraform_remote_state
# Usage: data.terraform_remote_state.sg.outputs.security_group_ids["rds_sg"]
output "security_group_ids" {
  description = "Map of logical SG key → SG ID"
  value       = { for k, v in aws_security_group.this : k => v.id }
}

# Secondary output — lookup by SG name (for compute module which uses name-based lookup)
# Usage: data.terraform_remote_state.sg.outputs.security_group_name_to_id["1111_FW_DEV_S1_1"]
output "security_group_name_to_id" {
  description = "Map of SG name → SG ID"
  value       = { for k, v in aws_security_group.this : v.name => v.id }
}

# Full details — for debugging / audit
output "security_groups" {
  description = "Full map of all created security groups with id, name, arn"
  value = {
    for k, v in aws_security_group.this : k => {
      id   = v.id
      name = v.name
      arn  = v.arn
    }
  }
}
