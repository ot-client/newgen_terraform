variable "identifier" {
  type    = string
  default = ""
}

variable "engine" {
  type    = string
  default = ""
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "instance_class" {
  type    = string
  default = ""
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "db_name" {
  type    = string
  default = ""
}

variable "username" {
  type    = string
  default = ""
}

variable "password" {
  type    = string
  default = ""
}

variable "port" {
  type    = number
  default = 3306
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "rds_security_group_id" {
  type    = string
  default = "null"
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "maintenance_window" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type    = string
  default = "03:00-06:00"
}

variable "monitoring_interval" {
  type    = number
  default = 60
}

variable "enhanced_monitoring_role_enabled" {
  type    = bool
  default = false
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "performance_insights_kms_key_id" {
  type    = string
  default = ""
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "is_cluster" {
  type    = bool
  default = false
}

variable "cluster_instance_count" {
  type    = number
  default = 1
}

variable "db_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "parameter_family" {
  type    = string
  default = ""
}

variable "enable_rds_proxy" {
  type    = bool
  default = false
}

variable "rds_proxy_name" {
  type    = string
  default = ""
}

variable "rds_proxy_secrets_arn" {
  type    = string
  default = ""
}

variable "iam_database_authentication_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_public_rds_security_group_resource" {
  type        = bool
  default     = true
  description = "This variable is to create Web Security Group"
}

variable "enable_public_ec2_security_group_resource" {
  type        = bool
  default     = true
  description = "This variable is to create Web Security Group"
}

variable "rds_sg_name" {
  type    = string
  default = "dev_sg"
}

variable "ec2_sg_name" {
  type    = string
  default = "dev_sg"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "existing_sg_id" {
  type    = string
  default = ""
}

variable "create_ec2_instance" {
  description = "Toggle to create EC2 instance"
  type        = bool
  default     = true
}

variable "count_ec2_instance" {
  type    = number
  default = 1
}

variable "existing_instance_id" {
  description = "Provide this when not creating EC2 but need to attach EBS to an existing instance"
  type        = string
  default     = "i-09460f2f0f2b8a8b2"
}

variable "ami_id" {
  type    = string
  default = "ami-020cba7c55df1f615"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "terra"
}

variable "subnet" {
  type    = list(string)
  default = ["subnet-045f69efd16f93d00"]
}

variable "public_ip" {
  type    = bool
  default = true
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "ebs_optimized" {
  type    = bool
  default = true
}

variable "user_data" {
  type    = string
  default = ""
}

variable "private_ip" {
  type    = string
  default = null
}

variable "volume_size" {
  type    = number
  default = 8
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "encrypted_volume" {
  type    = bool
  default = true
}

variable "root_block_iops" {
  type    = number
  default = 3000
}

variable "root_block_delete_on_termination" {
  type    = bool
  default = true
}

variable "metadata_http_tokens" {
  type    = string
  default = "required"
}

variable "metadata_http_endpoint" {
  type    = string
  default = "enabled"
}

variable "metadata_tags" {
  type    = string
  default = "enabled"
}

variable "enable_enclave" {
  type    = bool
  default = false
}

variable "auto_recovery" {
  type    = string
  default = "default"
}

variable "create_ebs_volume" {
  type    = bool
  default = false
}

variable "attach_existing_ebs_volume" {
  type    = bool
  default = false
}

variable "secondary_ebs_volumes" {
  type = list(object({
    device_name          = string
    volume_size          = number
    encrypted            = bool
    kms_key_id           = optional(string)
    final_snapshot       = optional(bool)
    multi_attach_enabled = optional(bool)
    iops                 = optional(number)
    throughput           = optional(number)
    type                 = string
    snapshot_id          = optional(string)
    outpost_arn          = optional(string)
    tags                 = optional(map(string), {})
  }))
  default = [
    {
      device_name = "/dev/sdf"
      volume_size = 20
      encrypted   = true
      type        = "gp3"
      tags = {
        Purpose = "AppData"
      }
    }
  ]
}

variable "secondary_existing_ebs_volumes" {
  type = list(object({
    device_name = string
    volume_id   = string
  }))
  default = [
    {
      device_name = "/dev/sdg"
      volume_id   = "vol-0c181fc4efb8832d5"
    }
  ]
}

variable "existing_rds_sg_id" {
  type    = string
  default = ""
}

variable "env" {
  type = string
  default = "dev"
  
}

variable "owner" {
  type = string
  default = "opstree"
}

variable "app" {
  type = string
  default = "otcloud-kit"
  
}

variable "region" {
  type = string
  default = "us-east-1"
  
}