
module "rds_security_group" {
  count  = var.enable_public_rds_security_group_resource ? 1 : 0
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-security-groups.git?ref=v.0.0.4"

  name   = var.rds_sg_name
  vpc_id = var.vpc_id
  tags   = var.tag
  aws_security_group_variables = [
    {
      description = "RDS SG Rules"

      aws_security_group_ingress = [
        {
          description     = "Allow MySQL from EC2 SG"
          from_port       = 3306
          to_port         = 3306
          protocol        = "tcp"
          security_groups = var.enable_public_ec2_security_group_resource ? [module.ec2_security_group[0].id[0]] : []
        },
        {
          description = "Allow MySQL from CIDR"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
        }
      ]

      aws_security_group_egress = [
        {
          description = "Allow all outbound"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]
}


module "ec2_security_group" {
  count  = var.enable_public_ec2_security_group_resource ? 1 : 0
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-security-groups.git?ref=v.0.0.4"

  name   = var.ec2_sg_name
  vpc_id = var.vpc_id
  tags   = var.tag

  aws_security_group_variables = [
    {
      description = "EC2 SG Rules"

      aws_security_group_ingress = [
        {
          description = "Allow SSH from anywhere"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      aws_security_group_egress = [
        {
          description = "Allow all outbound"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]
}

module "rds" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-rds.git?ref=Feature"

  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az
  db_name           = var.db_name
  username          = var.username
  password          = var.password
  port              = var.port
  subnet_ids        = var.subnet_ids

  rds_security_group_id = var.existing_rds_sg_id != "" ? var.existing_rds_sg_id : (
    var.enable_public_rds_security_group_resource ? module.rds_security_group[0].id[0] : ""
  )
app = var.app
env = var.env
owner = var.owner
  skip_final_snapshot                 = var.skip_final_snapshot
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  maintenance_window                  = var.maintenance_window
  backup_window                       = var.backup_window
  monitoring_interval                 = var.monitoring_interval
  enhanced_monitoring_role_enabled    = var.enhanced_monitoring_role_enabled
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.performance_insights_kms_key_id
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  deletion_protection                 = var.deletion_protection
  is_cluster                          = var.is_cluster
  cluster_instance_count              = var.cluster_instance_count
  db_parameters                       = var.db_parameters
  parameter_family                    = var.parameter_family
  enable_rds_proxy                    = var.enable_rds_proxy
  rds_proxy_name                      = var.rds_proxy_name
  rds_proxy_secrets_arn               = var.rds_proxy_secrets_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  tags                                = module.standard_tags.standard_tags
}

module "ec2_with_optional_ebs" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-ec2-instance.git?ref=Feature"

  create_ec2_instance     = var.create_ec2_instance
  existing_instance_id    = var.existing_instance_id
  count_ec2_instance      = var.count_ec2_instance
  ami_id                  = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet                  = var.subnet
  public_ip               = var.public_ip
  iam_instance_profile    = var.iam_instance_profile
  disable_api_termination = var.disable_api_termination
  enable_monitoring       = var.enable_monitoring
  ebs_optimized           = var.ebs_optimized
  user_data               = var.user_data != "" ? var.user_data : null
  private_ip              = var.private_ip

  volume_size                      = var.volume_size
  volume_type                      = var.volume_type
  encrypted_volume                 = var.encrypted_volume
  root_block_iops                  = var.root_block_iops
  root_block_delete_on_termination = var.root_block_delete_on_termination

  metadata_http_tokens   = var.metadata_http_tokens
  metadata_http_endpoint = var.metadata_http_endpoint
  metadata_tags          = var.metadata_tags

  enable_enclave = var.enable_enclave
  auto_recovery  = var.auto_recovery

  app = var.app
  owner = var.owner
  env = var.env
  create_ebs_volume          = var.create_ebs_volume
  attach_existing_ebs_volume = var.attach_existing_ebs_volume

  secondary_ebs_volumes          = var.secondary_ebs_volumes
  secondary_existing_ebs_volumes = var.secondary_existing_ebs_volumes

  instance_sg_id = var.existing_sg_id != "" ? var.existing_sg_id : (
    var.enable_public_ec2_security_group_resource ? module.ec2_security_group[0].id[0] : ""
  )
}
