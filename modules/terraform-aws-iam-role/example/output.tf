output "iam_roles_summary" {
  description = "IAM Roles summary (IDs, Names, ARNs)"
  value       = module.assume_role.role
}

output "iam_policies_summary" {
  description = "IAM Policies summary (IDs, Names, ARNs)"
  value       = module.assume_role.policy
}

output "iam_roles_detailed" {
  description = "Detailed IAM role information (name, arn, description)"
  value       = module.assume_role.roles
}

output "iam_policies_detailed" {
  description = "Detailed IAM policy information (name, arn, description)"
  value       = module.assume_role.policies
}

output "iam_role_policy_attachments" {
  description = "List of policy ARNs attached to IAM roles"
  value       = module.assume_role.aws_iam_role_policy_attachment_output
}
