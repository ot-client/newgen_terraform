output "resolver_rule_ids" {
  description = "Map of rule name => Resolver Rule ID"
  value       = { for k, v in aws_route53_resolver_rule.this : k => v.id }
}

output "resolver_rule_arns" {
  description = "Map of rule name => Resolver Rule ARN"
  value       = { for k, v in aws_route53_resolver_rule.this : k => v.arn }
}

output "association_ids" {
  description = "Map of association key => Association ID"
  value       = { for k, v in aws_route53_resolver_rule_association.this : k => v.id }
}
