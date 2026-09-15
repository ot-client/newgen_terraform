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
