# Terraform AWS S3 Bucket

A Terraform module to provision **highly configurable and secure AWS S3 buckets**, supporting features like:

- Versioning  
- Server-side encryption  
- Lifecycle policies  
- Logging  
- Fine-grained access control  

Suitable for production-grade S3 use cases with customization options for logging, replication, metrics, CORS, and more.

---

## Architecture

<img width="1189" height="492" alt="image" src="https://github.com/user-attachments/assets/d4548e51-0db1-4e95-89e8-9e5c338751d0" />


> **Note:**  
> The diagram below illustrates the core components managed by this module: S3 bucket, logging, versioning, lifecycle rules, policies, encryption, and replication.

---

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2   |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1|


## Usage

```hcl
module "s3_bucket" {
  source = "../"  

  create_bucket                  = true
  name                           = "OT-cloud-s3-bucket"
  bucket_prefix                  = null
  force_destroy                  = true
  object_lock_enabled            = false
  enable_transfer_acceleration   = true

  acl                            = "private"
  attach_public_policy           = true
  block_public_acls              = true
  block_public_policy            = true
  ignore_public_acls             = true
  restrict_public_buckets        = true

  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true
  attach_cloudtrail_policy       = true
  attach_iam_policy              = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  cors_rules = [
    {
      id              = "example-cors-rule"
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  server_side_encryption_configuration = [
    {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
        kms_master_key_id = null
      }
    }
  ]

  logging = {
    target_bucket = "my-logging-bucket"
    target_prefix = "logs/"
  }

  versioning = {
    enabled    = true
    status     = "Enabled"
    mfa_delete = false
  }

  lifecycle_rules = [
    {
      id         = "log-expiration"
      status     = "Enabled"
      expiration_days = 365
      transitions = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  metric_configuration = [
    {
      id   = "all-objects"
      name = "AllObjectsMetric"
      filter = [
        {
          prefix = "logs/"
          tags   = {
            Environment = "dev"
          }
        }
      ]
    }
  ]

  elb_service_accounts = {
    "us-east-1" = "127311923021"
  }

  elb_identifier      = "logdelivery.elb.amazonaws.com"
  lb_identifier       = "logdelivery.elasticloadbalancing.amazonaws.com"
  log_delivery_folder = "delivery"
  lb_log_delivery_conditions = {}

  crr_enabled                = true
  replication_destination_arn = "arn:aws:s3:::destination-bucket"
}


```
## Resources
| Name                                                                                                                                                                                   | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws\_s3\_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                               | Resource    |
| [aws\_s3\_bucket\_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                      | Resource    |
| [aws\_s3\_bucket\_accelerate\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration)                           | Resource    |
| [aws\_s3\_bucket\_cors\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration)                                       | Resource    |
| [aws\_s3\_bucket\_lifecycle\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                             | Resource    |
| [aws\_s3\_bucket\_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                              | Resource    |
| [aws\_s3\_bucket\_metric](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_metric)                                                                | Resource    |
| [aws\_s3\_bucket\_ownership\_controls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                                       | Resource    |
| [aws\_s3\_bucket\_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                                | Resource    |
| [aws\_s3\_bucket\_public\_access\_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                    | Resource    |
| [aws\_s3\_bucket\_replication\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration)                         | Resource    |
| [aws\_s3\_bucket\_server\_side\_encryption\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | Resource    |
| [aws\_s3\_bucket\_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                        | Resource    |
| [aws\_s3\_bucket\_website\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration)                                 | Resource    |
| [aws\_iam\_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                                 | Resource    |
| [aws\_iam\_role\_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                                  | Resource    |
| [aws\_iam\_policy\_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                       | Data Source |
| [aws\_caller\_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                                | Data Source |
| [aws\_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                                   | Data Source |
| [aws\_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                                                             | Data Source |


## Input 

| Name                                                                                  | Description                                                      | Type           | Default                                            | Required |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------- | -------------------------------------------------- | :------: |
| [`create_bucket`](#input_create_bucket)                                               | Whether to create the S3 bucket                                  | `bool`         | `false`                                            |     yes    |
| [`name`](#input_name)                                                                 | Name of the S3 bucket                                            | `string`       | `""`                                               |     yes    |
| [`bucket_prefix`](#input_bucket_prefix)                                               | Prefix to prepend to the bucket name (used if `name` is not set) | `string`       | `null`                                             |     No    |
| [`force_destroy`](#input_force_destroy)                                               | Whether to force destroy the bucket even if it contains objects  | `bool`         | `false`                                            |     No    |
| [`object_lock_enabled`](#input_object_lock_enabled)                                   | Enable S3 object lock configuration                              | `bool`         | `false`                                            |     No   |
| [`enable_transfer_acceleration`](#input_enable_transfer_acceleration)                 | Enable S3 transfer acceleration                                  | `bool`         | `false`                                            |     No    |
| [`acl`](#input_acl)                                                                   | Canned ACL to apply                                              | `string`       | `"private"`                                        |     No    |
| [`attach_public_policy`](#input_attach_public_policy)                                 | Whether to attach a public access block policy                   | `bool`         | `false`                                            |     No    |
| [`block_public_acls`](#input_block_public_acls)                                       | Block public ACLs for the bucket                                 | `bool`         | `true`                                             |     No    |
| [`block_public_policy`](#input_block_public_policy)                                   | Block public bucket policies                                     | `bool`         | `true`                                             |     No    |
| [`ignore_public_acls`](#input_ignore_public_acls)                                     | Ignore public ACLs                                               | `bool`         | `true`                                             |     No   |
| [`restrict_public_buckets`](#input_restrict_public_buckets)                           | Restrict public bucket access                                    | `bool`         | `true`                                             |     No    |
| [`attach_cloudtrail_policy`](#input_attach_cloudtrail_policy)                         | Attach CloudTrail log delivery policy                            | `bool`         | `false`                                            |     No    |
| [`attach_elb_log_delivery_policy`](#input_attach_elb_log_delivery_policy)             | Attach ELB log delivery policy                                   | `bool`         | `false`                                            |     No    |
| [`attach_lb_log_delivery_policy`](#input_attach_lb_log_delivery_policy)               | Attach ALB/NLB log delivery policy                               | `bool`         | `false`                                            |     No    |
| [`attach_iam_policy`](#input_attach_iam_policy)                                       | Whether to attach a custom IAM policy                            | `bool`         | `false`                                            |     No    |
| [`iam_policy`](#input_iam_policy)                                                     | Custom IAM policy JSON string                                    | `string`       | `""`                                               |     No    |
| [`control_object_ownership`](#input_control_object_ownership)                         | Whether to set object ownership controls                         | `bool`         | `false`                                            |     No    |
| [`object_ownership`](#input_object_ownership)                                         | Ownership setting for the bucket (`BucketOwnerEnforced`, etc.)   | `string`       | `"BucketOwnerEnforced"`                            |     No    |
| [`cors_rules`](#input_cors_rules)                                                     | List of CORS rules                                               | `list(object)` | `[]`                                               |     No   |
| [`server_side_encryption_configuration`](#input_server_side_encryption_configuration) | SSE configuration for the bucket                                 | `list(object)` | `[]`                                               |     No    |
| [`logging`](#input_logging)                                                           | Logging configuration for the bucket                             | `object`       | `{}`                                               |     No   |
| [`versioning`](#input_versioning)                                                     | Versioning configuration for the bucket                          | `object`       | `{}`                                               |     No    |
| [`lifecycle_rules`](#input_lifecycle_rules)                                           | Lifecycle rules for S3 objects                                   | `list(object)` | `[]`                                               |     No    |
| [`metric_configuration`](#input_metric_configuration)                                 | S3 metrics configuration block                                   | `list(object)` | `[]`                                               |     No   |
| [`elb_service_accounts`](#input_elb_service_accounts)                                 | Mapping of ELB service account IDs by region                     | `map(string)`  | `{}`                                               |     No    |
| [`elb_identifier`](#input_elb_identifier)                                             | ELB service principal name                                       | `string`       | `"logdelivery.elb.amazonaws.com"`                  |     No    |
| [`lb_identifier`](#input_lb_identifier)                                               | ALB/NLB service principal name                                   | `string`       | `"logdelivery.elasticloadbalancing.amazonaws.com"` |     No   |
| [`log_delivery_folder`](#input_log_delivery_folder)                                   | Folder inside bucket for log delivery                            | `string`       | `"logs"`                                           |     No    |
| [`lb_log_delivery_conditions`](#input_lb_log_delivery_conditions)                     | Conditions to apply LB log delivery policy                       | `map(any)`     | `{}`                                               |     No    |
| [`crr_enabled`](#input_crr_enabled)                                                   | Enable cross-region replication                                  | `bool`         | `false`                                            |     No   |
| [`replication_destination_arn`](#input_replication_destination_arn)                   | ARN of the destination bucket for replication                    | `string`       | `""`                                               |     No    |


___

## Output

| Name                                                                   | Description                                                                              |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [`bucket_name`](#output_bucket_name)                                   | Name of the created S3 bucket                                                            |
| [`bucket_arn`](#output_bucket_arn)                                     | ARN of the created S3 bucket                                                             |
| [`bucket_domain_name`](#output_bucket_domain_name)                     | The bucket domain name (e.g., `bucket-name.s3.amazonaws.com`)                            |
| [`bucket_regional_domain_name`](#output_bucket_regional_domain_name)   | The regional domain name of the bucket (e.g., `bucket-name.s3.ap-south-1.amazonaws.com`) |
| [`bucket_website_endpoint`](#output_bucket_website_endpoint)           | Static website endpoint (if website hosting is enabled)                                  |
| [`transfer_acceleration_status`](#output_transfer_acceleration_status) | Transfer acceleration status of the bucket                                               |
| [`bucket_versioning_status`](#output_bucket_versioning_status)         | The versioning status of the bucket                                                      |
| [`bucket_sse_algorithm`](#output_bucket_sse_algorithm)                 | SSE algorithm used for default encryption                                                |
| [`logging_target_bucket`](#output_logging_target_bucket)               | Target bucket for server access logging                                                  |
| [`ownership_control`](#output_ownership_control)                       | Object ownership setting of the bucket                                                   |
| [`replication_role_arn`](#output_replication_role_arn)                 | IAM role ARN used for cross-region replication                                           |
| [`elb_identifier`](#output_elb_identifier)                             | ELB log delivery service identifier                                                      |
| [`lb_identifier`](#output_lb_identifier)                               | ALB/NLB log delivery service identifier                                                  |

___

## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)

