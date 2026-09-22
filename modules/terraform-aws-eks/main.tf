resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn                  = aws_iam_role.cluster_role.arn
  version                   = var.eks_cluster_version
  deletion_protection       = var.deletion_protection

  access_config {
    authentication_mode = var.access_mode
  }

  upgrade_policy {
    support_type = var.support_type
  }

  tags = merge(
    { Name = format("%s-cluster", var.cluster_name) },
    local.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_managed_policies
  ]

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = var.endpoint_private
    endpoint_public_access  = var.endpoint_public
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = concat([aws_security_group.cluster_sg.id], var.additional_security_group_ids)
  }

  kubernetes_network_config {
    ip_family = var.ip_family
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  zonal_shift_config {
    enabled = var.zonal_shift_enabled
  }
}

module "node_group" {
  source            = "git::https://github.com/ot-client/newgen_terraform.git//modules/terraform-aws-node-group?ref=main"
  create_node_group = var.create_node_group
  cluster_name      = aws_eks_cluster.eks_cluster.id

  node_groups = {
    for ng_key, ng in var.node_groups : ng_key => merge(ng, {
      node_role_arn = aws_iam_role.node_group_role[ng_key].arn
    })
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_managed_policies,
    aws_iam_role_policy.node_inline_policies
  ]
}

resource "aws_iam_role" "cluster_role" {
  name = coalesce(var.cluster_role_name, "${var.cluster_name}-cluster-role")

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "eks.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
POLICY

  tags = merge(
    { Name = coalesce(var.cluster_role_name, "${var.cluster_name}-cluster-role") },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "cluster_managed_policies" {
  for_each   = toset(var.cluster_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "node_group_role" {
  for_each = var.node_groups
  name     = each.value.iam_node_group_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(
    { Name = "${each.value.iam_node_group_role_name}-iam-role" },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "node_managed_policies" {
  for_each = {
    for pair in flatten([
      for ng_key, ng in var.node_groups : [
        for policy_arn in ng.node_group_managed_policies : {
          key        = "${ng_key}-${md5(policy_arn)}"
          role_name  = aws_iam_role.node_group_role[ng_key].name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }
  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "node_inline_policies" {
  for_each = {
    for pair in flatten([
      for ng_key, _ in var.node_groups : [
        for policy_name, policy_json in var.node_group_inline_policies : {
          key         = "${ng_key}-${policy_name}"
          role_name   = aws_iam_role.node_group_role[ng_key].name
          policy_name = policy_name
          policy_json = policy_json
        }
      ]
    ]) : pair.key => pair
  }
  name   = each.value.policy_name
  role   = each.value.role_name
  policy = each.value.policy_json
}

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group" "cluster_sg" {
  name                    = "${var.cluster_name}-cluster-sg"
  description             = "Custom SG for EKS cluster - no default all traffic rule"
  vpc_id                  = var.vpc_id
  revoke_rules_on_delete  = true

  tags = merge(
    { Name = "${var.cluster_name}-cluster-sg" },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_sg_rules" {
  for_each = var.cluster_sg_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.source_sg_id == null ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id
  security_group_id        = aws_security_group.cluster_sg.id
}

resource "null_resource" "revoke_default_egress" {
  triggers = {
    cluster_sg_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 revoke-security-group-egress \
        --region ${var.region} \
        --group-id ${aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id} \
        --ip-permissions '[{"IpProtocol":"-1","IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' 2>/dev/null || true
    EOT
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "addons" {
  count         = length(var.eks_addons)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = var.eks_addons[count.index].name
  addon_version = var.eks_addons[count.index].version

  tags = merge(
    { Name = "${var.cluster_name}-${var.eks_addons[count.index].name}-addon" },
    local.common_tags
  )
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "sso_role" {
  for_each      = var.aws_sso_role_arn != null ? { "sso" = var.aws_sso_role_arn } : {}
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_role_policy" {
  for_each      = aws_eks_access_entry.sso_role
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "additional" {
  for_each      = var.access_entries
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "additional_policy" {
  for_each      = aws_eks_access_entry.additional
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}