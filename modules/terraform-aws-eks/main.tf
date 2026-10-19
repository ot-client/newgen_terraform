data "aws_iam_role" "cluster_role" {
  name = var.cluster_role_name
}

data "aws_iam_role" "node_group_role" {
  for_each = var.node_groups
  name     = each.value.iam_node_group_role_name
}

resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn                  = data.aws_iam_role.cluster_role.arn
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
    data.aws_iam_role.cluster_role
  ]

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = var.endpoint_private
    endpoint_public_access  = var.endpoint_public
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = concat(aws_security_group.cluster_sg[*].id, var.additional_security_group_ids)
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
  source       = "../terraform-aws-node-group"
  cluster_name = aws_eks_cluster.eks_cluster.id

  node_groups = {
    for ng_key, ng in var.node_groups : ng_key => merge(ng, {
      node_role_arn = data.aws_iam_role.node_group_role[ng_key].arn
    })
  }

  depends_on = [
    data.aws_iam_role.node_group_role
  ]
}

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group" "cluster_sg" {
  count                  = var.create_cluster_sg ? 1 : 0
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
  for_each = var.create_cluster_sg ? var.cluster_sg_rules : {}

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  description              = each.value.description
  cidr_blocks              = each.value.source_sg_id == null ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id
  security_group_id        = aws_security_group.cluster_sg[0].id
}

# ── EKS-created default cluster security group (vpc_config[0].cluster_security_group_id) ──
# EKS creates this SG with "allow all from self" ingress and "allow all" egress.
# Optionally revoke those defaults, then manage the rules from tfvars (default_cluster_sg_rules).
locals {
  default_cluster_sg_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "null_resource" "revoke_default_cluster_sg_rules" {
  count = var.revoke_default_cluster_sg_egress || var.revoke_default_cluster_sg_ingress ? 1 : 0

  triggers = {
    cluster_sg_id = local.default_cluster_sg_id
    egress        = var.revoke_default_cluster_sg_egress
    ingress       = var.revoke_default_cluster_sg_ingress
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      %{if var.revoke_default_cluster_sg_egress~}
      aws ec2 revoke-security-group-egress --region ${var.region} --group-id ${local.default_cluster_sg_id} \
        --ip-permissions '[{"IpProtocol":"-1","IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' 2>/dev/null || true
      %{endif~}
      %{if var.revoke_default_cluster_sg_ingress~}
      aws ec2 revoke-security-group-ingress --region ${var.region} --group-id ${local.default_cluster_sg_id} \
        --ip-permissions '[{"IpProtocol":"-1","UserIdGroupPairs":[{"GroupId":"${local.default_cluster_sg_id}"}]}]' 2>/dev/null || true
      %{endif~}
    EOT
  }
}

resource "aws_vpc_security_group_ingress_rule" "default_cluster_sg" {
  for_each = { for k, r in var.default_cluster_sg_rules : k => r if r.type == "ingress" }

  security_group_id            = local.default_cluster_sg_id
  description                  = each.value.description
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4                    = each.value.cidr_block
  referenced_security_group_id = each.value.self ? local.default_cluster_sg_id : each.value.source_sg_id

  tags = merge({ Name = "${var.cluster_name}-default-sg-${each.key}" }, local.common_tags)

  depends_on = [null_resource.revoke_default_cluster_sg_rules]
}

resource "aws_vpc_security_group_egress_rule" "default_cluster_sg" {
  for_each = { for k, r in var.default_cluster_sg_rules : k => r if r.type == "egress" }

  security_group_id            = local.default_cluster_sg_id
  description                  = each.value.description
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4                    = each.value.cidr_block
  referenced_security_group_id = each.value.self ? local.default_cluster_sg_id : each.value.source_sg_id

  tags = merge({ Name = "${var.cluster_name}-default-sg-${each.key}" }, local.common_tags)

  depends_on = [null_resource.revoke_default_cluster_sg_rules]
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

# ── Access entries ────────────────────────────────────────────────────────────
# Supported types: STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX, HYBRID_LINUX
# Policies (AmazonEKSAdminPolicy / AmazonEKSClusterAdminPolicy / ...) can be attached
# at cluster scope or namespace scope (e.g. dev / uat / prod namespaces).
locals {
  access_policy_prefix = "arn:aws:eks::aws:cluster-access-policy"

  # SSO role (legacy variable) is folded into the same model as a cluster-admin STANDARD entry
  all_access_entries = merge(
    var.aws_sso_role_arn != null ? {
      "sso" = {
        principal_arn     = var.aws_sso_role_arn
        type              = "STANDARD"
        user_name         = null
        kubernetes_groups = []
        policies          = { cluster_admin = { policy = "AmazonEKSClusterAdminPolicy", scope = "cluster", namespaces = [] } }
      }
    } : {},
    var.access_entries
  )

  access_policy_associations = {
    for pair in flatten([
      for entry_key, entry in local.all_access_entries : [
        for policy_key, p in entry.policies : {
          key           = "${entry_key}/${policy_key}"
          entry_key     = entry_key
          principal_arn = entry.principal_arn
          policy_arn    = startswith(p.policy, "arn:") ? p.policy : "${local.access_policy_prefix}/${p.policy}"
          scope         = p.scope
          namespaces    = p.namespaces
        }
      ]
    ]) : pair.key => pair
  }
}

resource "aws_eks_access_entry" "this" {
  for_each = local.all_access_entries

  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  user_name         = each.value.user_name
  kubernetes_groups = length(each.value.kubernetes_groups) > 0 ? each.value.kubernetes_groups : null

  tags = merge(
    { Name = "${var.cluster_name}-${each.key}-access-entry" },
    local.common_tags
  )
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.access_policy_associations

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.this[each.value.entry_key].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.scope
    namespaces = each.value.scope == "namespace" ? each.value.namespaces : null
  }
}
