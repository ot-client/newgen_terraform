
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main[0].bucket
}


output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main[0].arn
}



output "bucket_domain_name" {
  description = "The bucket domain name (e.g., bucket-name.s3.amazonaws.com)"
  value       = aws_s3_bucket.main[0].bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket (e.g., bucket-name.s3.ap-south-1.amazonaws.com)"
  value       = aws_s3_bucket.main[0].bucket_regional_domain_name
}

output "bucket_website_endpoint" {
  description = "Static website endpoint (if website hosting is enabled)"
  value       = try(aws_s3_bucket_website_configuration.website[0].website_endpoint, null)
}

output "transfer_acceleration_status" {
  description = "Transfer acceleration status of the bucket"
  value       = try(aws_s3_bucket_accelerate_configuration.acceleration[0].status, "Disabled")
}

output "bucket_versioning_status" {
  description = "The versioning status of the bucket"
  value       = try(aws_s3_bucket_versioning.versioning[0].versioning_configuration[0].status, "Disabled")
}

output "bucket_sse_algorithm" {
  description = "SSE algorithm used for default encryption"
  value = try([
    for rule in aws_s3_bucket_server_side_encryption_configuration.encryption[0].rule :
    rule.apply_server_side_encryption_by_default[0].sse_algorithm
  ][0], "None")
}

output "logging_target_bucket" {
  description = "Target bucket for server access logging"
  value       = try(aws_s3_bucket_logging.logging[0].target_bucket, null)
}

output "ownership_control" {
  description = "Object ownership setting of the bucket"
  value       = try(aws_s3_bucket_ownership_controls.ownership_controls[0].rule[0].object_ownership, "Not Set")
}

output "replication_role_arn" {
  description = "IAM role ARN used for cross-region replication"
  value       = try(aws_iam_role.replication.arn, null)
}

output "elb_identifier" {
  description = "ELB log delivery service identifier"
  value = try(flatten([
    for statement in data.aws_iam_policy_document.elb_log_delivery[0].statement :
    [
      for principal in statement.principals :
      flatten([principal.identifiers]) if can(principal.identifiers) && principal.type == "Service"
    ]
  ])[0], null)
}

output "lb_identifier" {
  description = "ALB/NLB log delivery service identifier"
  value = try([
    for statement in data.aws_iam_policy_document.lb_log_delivery[0].statement :
    [
      for principal in statement.principals :
      flatten([principal.identifiers])[0]
      if can(principal.identifiers) && principal.type == "Service"
    ][0]
    if can(statement.principals)
  ][0], null)
}
