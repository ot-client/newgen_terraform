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
