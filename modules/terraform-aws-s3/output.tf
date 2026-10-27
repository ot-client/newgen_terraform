output "bucket_id" {
  value = try(aws_s3_bucket.main[0].id, null)
}

output "bucket_arn" {
  value = try(aws_s3_bucket.main[0].arn, null)
}

output "replication_role_arn" {
  description = "ARN of the IAM role created for replication (null if replication disabled)"
  value       = try(aws_iam_role.replication[0].arn, null)
}

output "bucket_region" {
  description = "AWS region the bucket was created in"
  value       = try(aws_s3_bucket.main[0].bucket_region, null)
}

output "website_endpoint" {
  description = "Static website endpoint (null if website hosting disabled)"
  value       = try(aws_s3_bucket_website_configuration.website[0].website_endpoint, null)
}

output "website_domain" {
  description = "Static website domain, used for Route 53 alias records (null if website hosting disabled)"
  value       = try(aws_s3_bucket_website_configuration.website[0].website_domain, null)
}
