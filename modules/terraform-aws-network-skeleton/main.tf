######################################
# VPC
######################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  # Name tag uses vpc_name variable; all other common tags (Environment, Project, etc.) are merged in
  tags = merge(
    { Name = var.vpc_name },
    local.common_tags
  )
}

######################################
# Subnets
######################################
resource "aws_subnet" "subnets" {
  count = length(local.subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnets[count.index].cidr
  availability_zone = local.subnets[count.index].az

  tags = merge(
    {
      Name = local.subnets[count.index].name
    },
    local.common_tags
  )
}

######################################
# Internet Gateway
######################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  # Name tag uses internet_gateway_name variable; all other common tags are merged in
  tags = merge(
    { Name = var.internet_gateway_name },
    local.common_tags
  )
}

######################################
# Virtual Gateway
######################################

resource "aws_vpn_gateway" "vgw" {
  count = var.create_vgw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  # Name tag uses vgw_name variable; all other common tags are merged in
  tags = merge(
    { Name = var.vgw_name },
    local.common_tags
  )
}

######################################
# Elastic IPs for NAT Gateways
######################################
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? var.nat_gateway_count : 0
  domain = "vpc"

  # Name tag uses vpc_name as prefix for EIP; all other common tags are merged in
  tags = merge(
    { Name = "${var.vpc_name}-nat-eip-${count.index + 1}" },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

# ######################################
# # NAT Gateways
# ######################################
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.create_nat_gateway ? var.nat_gateway_count : 0
  subnet_id     = local.all_subnet_ids[count.index]
  allocation_id = aws_eip.nat[count.index].id

  # Name tag uses vpc_name as prefix for NAT Gateway; all other common tags are merged in
  tags = merge(
    { Name = "${var.vpc_name}-nat-${count.index + 1}" },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}



######################################
# Flow Logs
######################################
data "aws_caller_identity" "current_account" {}

resource "aws_s3_bucket" "flow_logs_bucket" {
  count         = var.flow_logs_enabled ? 1 : 0
  bucket        = format("%s-flow-logs-bucket", data.aws_caller_identity.current_account.account_id)
  force_destroy = true
}

resource "aws_flow_log" "vpc_flow_log" {
  count                = var.flow_logs_enabled ? 1 : 0
  log_destination      = aws_s3_bucket.flow_logs_bucket[0].arn
  log_destination_type = "s3"
  traffic_type         = var.flow_logs_traffic_type
  vpc_id               = aws_vpc.vpc.id

  destination_options {
    file_format        = var.flow_logs_file_format
    per_hour_partition = true
  }
}

######################################
# Route53
######################################
resource "aws_route53_zone" "vpc_route53" {
  count = var.create_route53 ? 1 : 0
  name  = var.route53_zone

  vpc {
    vpc_id = aws_vpc.vpc.id
  }

  # Name tag uses vpc_name as prefix for Route53 zone; all other common tags are merged in
  tags = merge(
    { Name = "${var.vpc_name}-route53" },
    local.common_tags
  )
}

######################################
# EC2 Key Pair (Generate and Save)
######################################

resource "tls_private_key" "ec2_key" {
  count     = var.create_key_pair && var.create_private_key ? 1 : 0
  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}

resource "aws_key_pair" "key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_pair_name
  public_key = var.create_private_key ? tls_private_key.ec2_key[0].public_key_openssh : file(var.public_key_path)

  # Name tag uses key_pair_name variable; all other common tags are merged in
  tags = merge(
    { Name = var.key_pair_name },
    local.common_tags
  )
}

resource "local_file" "private_key" {
  count           = var.create_key_pair && var.create_private_key ? 1 : 0
  content         = tls_private_key.ec2_key[0].private_key_pem
  filename        = "${var.key_output_dir}/${var.key_pair_name}.pem"
  file_permission = "0400"

  depends_on = [aws_key_pair.key_pair]
}
