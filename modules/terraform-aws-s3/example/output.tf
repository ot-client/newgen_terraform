
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_domain_name" {
  description = "The bucket domain name (e.g., bucket-name.s3.amazonaws.com)"
  value       = module.s3_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket"
  value       = module.s3_bucket.bucket_regional_domain_name
}

output "bucket_website_endpoint" {
  description = "Static website endpoint (if website hosting is enabled)"
  value       = module.s3_bucket.bucket_website_endpoint
}

output "transfer_acceleration_status" {
  description = "Transfer acceleration status of the bucket"
  value       = module.s3_bucket.transfer_acceleration_status
}

output "bucket_versioning_status" {
  description = "The versioning status of the bucket"
  value       = module.s3_bucket.bucket_versioning_status
}

output "bucket_sse_algorithm" {
  description = "SSE algorithm used for default encryption"
  value       = module.s3_bucket.bucket_sse_algorithm
}

output "logging_target_bucket" {
  description = "Target bucket for server access logging"
  value       = module.s3_bucket.logging_target_bucket
}

output "ownership_control" {
  description = "Object ownership setting of the bucket"
  value       = module.s3_bucket.ownership_control
}

output "replication_role_arn" {
  description = "IAM role ARN used for cross-region replication"
  value       = module.s3_bucket.replication_role_arn
}

output "elb_identifier" {
  description = "ELB log delivery service identifier"
  value       = module.s3_bucket.elb_identifier
}

output "lb_identifier" {
  description = "ALB/NLB log delivery service identifier"
  value       = module.s3_bucket.lb_identifier
}
