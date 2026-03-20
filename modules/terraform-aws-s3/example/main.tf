
module "s3_bucket" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-s3.git?ref=Feature"

  create_bucket                        = var.create_bucket
  name                                 = var.name
  bucket_prefix                        = var.bucket_prefix
  force_destroy                        = var.force_destroy
  object_lock_enabled                  = var.object_lock_enabled
  enable_transfer_acceleration         = var.enable_transfer_acceleration
  acl                                  = var.acl
  app = var.app
  owner = var.owner
  env = var.env
  attach_public_policy                 = var.attach_public_policy
  block_public_acls                    = var.block_public_acls
  block_public_policy                  = var.block_public_policy
  ignore_public_acls                   = var.ignore_public_acls
  restrict_public_buckets              = var.restrict_public_buckets
  attach_elb_log_delivery_policy       = var.attach_elb_log_delivery_policy
  attach_lb_log_delivery_policy        = var.attach_lb_log_delivery_policy
  attach_cloudtrail_policy             = var.attach_cloudtrail_policy
  attach_iam_policy                    = var.attach_iam_policy
  iam_policy                           = var.iam_policy
  control_object_ownership             = var.control_object_ownership
  object_ownership                     = var.object_ownership
  cors_rules                           = var.cors_rules
  server_side_encryption_configuration = var.server_side_encryption_configuration
  logging                              = var.logging
  versioning                           = var.versioning
  lifecycle_rules                      = var.lifecycle_rules
  metric_configuration                 = var.metric_configuration
  elb_service_accounts        = var.elb_service_accounts
  elb_identifier              = var.elb_identifier
  lb_identifier               = var.lb_identifier
  log_delivery_folder         = var.log_delivery_folder
  lb_log_delivery_conditions  = var.lb_log_delivery_conditions
  crr_enabled                 = var.crr_enabled
  replication_destination_arn = var.replication_destination_arn

}
