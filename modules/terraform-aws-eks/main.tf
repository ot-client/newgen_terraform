resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn                  = aws_iam_role.cluster_role.arn
  version                   = var.eks_cluster_version

  access_config {
    authentication_mode = var.access_mode
  }

  upgrade_policy {
    support_type = var.support_type
  }
  tags = merge(
    {
      Name = format("%s-cluster", var.cluster_name)
    },
    local.common_tags
  )
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
  ]

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = var.endpoint_private
    endpoint_public_access  = var.endpoint_public
    security_group_ids      = [aws_security_group.cluster_sg.id]
  }
  
}

module "node_group" {
  source            = "git::https://github.com/ot-client/newgen_terraform.git//modules/terraform-aws-node-group?ref=main"
  create_node_group = var.create_node_group
  cluster_name      = aws_eks_cluster.eks_cluster.id
  node_role_arn     = aws_iam_role.node_group_role.arn
  node_groups       = var.node_groups
  launch_template_id = var.launch_template_id

  depends_on = [
    aws_iam_role_policy_attachment.node_managed_policies,
    aws_iam_role_policy.node_inline_policies
  ]
}

resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge(
    {
      Name = format("%s-cluster_iam_role", var.cluster_name)
    },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = merge(
    {
      Name = format("%s-node_group_iam_role", var.eks_node_group_name)
    },
    local.common_tags
  )
}

# Attach AWS managed policies to node group role
resource "aws_iam_role_policy_attachment" "node_managed_policies" {
  for_each = toset(var.node_group_managed_policies)
  
  policy_arn = each.value
  role       = aws_iam_role.node_group_role.name
}

# Attach custom inline policies to node group role
resource "aws_iam_role_policy" "node_inline_policies" {
  for_each = var.node_group_inline_policies
  
  name   = each.key
  role   = aws_iam_role.node_group_role.name
  policy = each.value
}

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group" "cluster_sg" {
  name                 = "${var.cluster_name}-cluster-sg"
  description          = "Custom SG for EKS cluster - no default all traffic rule"
  vpc_id               = var.vpc_id
  revoke_rules_on_delete = true

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

# Remove default all-traffic egress rule from EKS-managed default cluster SG
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

  tags = merge({
    Name        = "${var.cluster_name}-${var.eks_addons[count.index].name}-addon"
  },
   local.common_tags
  )
  depends_on = [aws_eks_cluster.eks_cluster ]
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

# Additional IAM roles granted cluster access via access_entries variable
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
