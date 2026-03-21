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
  }
  
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

resource "aws_iam_role_policy" "node_group_s3_policy" {
  name = "${var.cluster_name}-node-s3-policy"
  role = aws_iam_role.node_group_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:List*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::1111-s3-dev-s1-1",
          "arn:aws:s3:::1111-s3-dev-s1-1/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group_rule" "cluster_private_access" {
  count       = var.cluster_endpoint_whitelist ? 1 : 0
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.cluster_endpoint_access_cidrs

  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
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
