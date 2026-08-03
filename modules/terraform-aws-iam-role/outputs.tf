output "role_arns" {
  value = {
    for k, r in aws_iam_role.roles :
    k => r.arn
  }
}

output "custom_policy_arns" {
  value = {
    for k, p in aws_iam_policy.custom :
    k => p.arn
  }
}

output "instance_profiles" {
  value = {
    for k, v in aws_iam_instance_profile.this :
    k => v.name
  }
}

output "role_all_policy_arns" {
  description = "Map of role name to all attached policy ARNs (managed + custom)"
  value = {
    for role, data in var.roles : role => concat(
      data.managed_policy_arns,
      [for p in data.custom_policy_names : aws_iam_policy.custom[p].arn]
    )
  }
}
