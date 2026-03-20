# terraform-aws-rds

This Terraform module provisions a fully managed **AWS RDS** instance supporting engines such as **PostgreSQL**, **MySQL**, or **MariaDB**. It includes subnet group creation, optional parameter group, and optional security group — with features supporting performance, reliability, and security.

---

## Features

- Supports PostgreSQL, MySQL, and MariaDB
- Optional Multi-AZ deployments
- Optional RDS Cluster and Proxy
- Enhanced Monitoring and Performance Insights
- Secure, encrypted storage with KMS

---

## Architecture
<img width="1219" height="598" alt="image" src="https://github.com/user-attachments/assets/594c12b8-c8f5-4d0d-8f7a-5a07164a0280" />

___

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2   |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1|

##  Usage

```hcl
module "rds_instance" {
  source = "OT-CLOUD-KIT/terraform-aws-rds"

  bu            = "bp"
  program       = "ot"
  app           = "backend"
  env           = "prod"
  region        = "us-east-1"
  team          = "devops"
  identifier    = "backend-db"

  engine        = "postgres"
  engine_version = "16"
  db_name        = "appdb"
  username       = "admin"
  password       = "SecurePass123!"

  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  multi_az              = true
  storage_encrypted     = true
  kms_key_id            = "arn:aws:kms:..."

  subnet_ids            = ["subnet-aaa", "subnet-bbb"]
  rds_security_group_id = "sg-123456"

  apply_immediately     = true
  backup_retention_period = 7
  maintenance_window    = "sun:04:00-sun:05:00"
  backup_window         = "03:00-04:00"

  skip_final_snapshot   = false
  deletion_protection   = true
  enhanced_monitoring_role_enabled = true
  monitoring_interval   = 60

  enable_rds_proxy      = true
  rds_proxy_name        = "backend-proxy"
  rds_proxy_secrets_arn = "arn:aws:secretsmanager:..."

  db_parameters = [
    {
      name  = "log_statement"
      value = "all"
    }
  ]

  tags = {
    Owner = "Team DevOps"
  }
}
```

> **Note:**  
> The above example demonstrates how to use the module. All variables, resources, and outputs used here are already defined within this module.



## Resources

| Name                              | Type                                                                                                                                 |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `aws_db_instance`                 | [RDS Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)                              |
| `aws_rds_cluster`                 | [RDS Cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)                               |
| `aws_rds_cluster_instance`        | [RDS Cluster Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance)             |
| `aws_db_subnet_group`             | [Subnet Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)                          |
| `aws_db_parameter_group`          | [Parameter Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group)                    |
| `aws_rds_cluster_parameter_group` | [Cluster Parameter Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group)   |
| `aws_db_proxy`                    | [RDS Proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy)                                    |
| `aws_iam_role`                    | [IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                     |
| `aws_iam_role_policy_attachment`  | [IAM Role Policy Attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |

___

## Input

| Name                                                                                                                                 | Description                                      | Type                | Default                 | Required |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------ | ------------------- | ----------------------- | :------: |
| <a name="input_identifier"></a> [identifier](#input_identifier)                                                                      | Unique RDS instance/cluster identifier           | `string`            | `null`                  |    yes   |
| <a name="input_engine"></a> [engine](#input_engine)                                                                                  | RDS engine type (`mysql`, `postgres`, `mariadb`) | `string`            | `null`                  |    yes   |
| <a name="input_engine_version"></a> [engine\_version](#input_engine_version)                                                         | Version of DB engine                             | `string`            | `null`                  |    yes   |
| <a name="input_db_name"></a> [db\_name](#input_db_name)                                                                              | Initial database name                            | `string`            | `null`                  |    yes   |
| <a name="input_username"></a> [username](#input_username)                                                                            | Master DB username                               | `string`            | `null`                  |    yes   |
| <a name="input_password"></a> [password](#input_password)                                                                            | Master DB password                               | `string`            | `null`                  |    yes   |
| <a name="input_instance_class"></a> [instance\_class](#input_instance_class)                                                         | DB instance class (e.g., `db.t3.micro`)          | `string`            | `"db.t3.micro"`         |    yes   |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input_allocated_storage)                                                | Storage size in GB                               | `number`            | `20`                    |    yes   |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input_kms_key_id)                                                                    | KMS key for storage encryption                   | `string`            | `""`                    |    no    |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input_storage_encrypted)                                                | Enable storage encryption                        | `bool`              | `true`                  |    no    |
| <a name="input_multi_az"></a> [multi\_az](#input_multi_az)                                                                           | Enable Multi-AZ deployment                       | `bool`              | `false`                 |    no    |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input_publicly_accessible)                                          | Whether the DB is publicly accessible            | `bool`              | `false`                 |    no    |
| <a name="input_vpc_id"></a> [vpc\_id](#input_vpc_id)                                                                                 | VPC ID for security group (if created)           | `string`            | `null`                  |    yes   |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input_subnet_ids)                                                                     | List of subnet IDs                               | `list(string)`      | `[]`                    |    yes   |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input_rds_security_group_id)                                  | Existing security group ID                       | `string`            | `""`                    |    no    |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input_backup_retention_period)                             | Retention period for backups (days)              | `number`            | `7`                     |    no    |
| <a name="input_backup_window"></a> [backup\_window](#input_backup_window)                                                            | Preferred backup time window                     | `string`            | `"03:00-04:00"`         |    no    |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input_maintenance_window)                                             | Preferred maintenance window                     | `string`            | `"sun:05:00-sun:06:00"` |    no    |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input_apply_immediately)                                                | Apply changes immediately                        | `bool`              | `true`                  |    no    |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input_skip_final_snapshot)                                         | Skip final snapshot on destroy                   | `bool`              | `true`                  |    no    |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input_deletion_protection)                                          | Prevent deletion                                 | `bool`              | `false`                 |    no    |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input_performance_insights_enabled)              | Enable Performance Insights                      | `bool`              | `false`                 |    no    |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input_performance_insights_kms_key_id)   | KMS key for Performance Insights                 | `string`            | `""`                    |    no    |
| <a name="input_enhanced_monitoring_role_enabled"></a> [enhanced\_monitoring\_role\_enabled](#input_enhanced_monitoring_role_enabled) | Enable IAM role for Enhanced Monitoring          | `bool`              | `false`                 |    no    |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input_monitoring_interval)                                          | Monitoring interval in seconds                   | `number`            | `0`                     |    no    |
| <a name="input_is_cluster"></a> [is\_cluster](#input_is_cluster)                                                                     | Whether this is an Aurora cluster                | `bool`              | `false`                 |    no    |
| <a name="input_cluster_instance_count"></a> [cluster\_instance\_count](#input_cluster_instance_count)                                | Number of cluster instances                      | `number`            | `2`                     |    no    |
| <a name="input_enable_rds_proxy"></a> [enable\_rds\_proxy](#input_enable_rds_proxy)                                                  | Enable RDS Proxy                                 | `bool`              | `false`                 |    no    |
| <a name="input_rds_proxy_name"></a> [rds\_proxy\_name](#input_rds_proxy_name)                                                        | Name for RDS Proxy                               | `string`            | `""`                    |    no    |
| <a name="input_rds_proxy_secrets_arn"></a> [rds\_proxy\_secrets\_arn](#input_rds_proxy_secrets_arn)                                  | Secrets Manager ARN for RDS Proxy auth           | `string`            | `""`                    |    no    |
| <a name="input_db_parameters"></a> [db\_parameters](#input_db_parameters)                                                            | List of parameter maps for DB                    | `list(map(string))` | `[]`                    |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                        | Tags to apply to all resources                   | `map(string)`       | `{}`                    |    no    |


___

## Output

| Name                                                                                                    | Description                                                     |
| ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| <a name="output_db_instance_identifier"></a> [db\_instance\_identifier](#output_db_instance_identifier) | The identifier of the RDS instance or cluster                   |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output_db_endpoint)                                   | The DNS endpoint address of the RDS instance or cluster         |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output_db_instance_arn)                      | The Amazon Resource Name (ARN) of the RDS instance              |
| <a name="output_db_cluster_identifier"></a> [db\_cluster\_identifier](#output_db_cluster_identifier)    | The identifier of the RDS cluster (only if `is_cluster = true`) |
| <a name="output_db_proxy_endpoint"></a> [db\_proxy\_endpoint](#output_db_proxy_endpoint)                | The RDS Proxy endpoint (if proxy is enabled)                    |
| <a name="output_monitoring_role_arn"></a> [monitoring\_role\_arn](#output_monitoring_role_arn)          | ARN of the IAM role for Enhanced Monitoring (if enabled)        |


___

## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)

