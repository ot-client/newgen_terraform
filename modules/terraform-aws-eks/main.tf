resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn                  = var.cluster_role_arn
  version                   = var.eks_cluster_version

  access_config {
    authentication_mode = var.access_mode
  }

  upgrade_policy {
    support_type = var.support_type
  }

  dynamic "compute_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      enabled       = true
      node_pools    = length(var.auto_mode_node_pools) > 0 ? var.auto_mode_node_pools : null
      node_role_arn = length(var.auto_mode_node_pools) > 0 ? var.node_role_arn : null
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      elastic_load_balancing {
        enabled = var.enable_elastic_load_balancing
      }
    }
  }

  dynamic "storage_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      block_storage {
        enabled = var.enable_block_storage
      }
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.zonal_shift_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "control_plane_scaling_config" {
    for_each = var.control_plane_scaling_tier != null ? [1] : []
    content {
      tier = var.control_plane_scaling_tier
    }
  }

  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons != null ? var.bootstrap_self_managed_addons : (var.enable_auto_mode ? false : null)
  deletion_protection           = var.deletion_protection

  tags = merge({ Name = format("%s-cluster", var.cluster_name) }, local.common_tags)

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = var.endpoint_private
    endpoint_public_access  = var.endpoint_public
  }

  timeouts {
    create = "45m"
    update = "60m"
    delete = "30m"
  }
}

module "node_group" {
  source             = "git::https://github.com/ot-client/newgen_terraform.git//modules/terraform-aws-node-group?ref=main"
  create_node_group  = var.enable_auto_mode ? false : var.create_node_group
  cluster_name       = aws_eks_cluster.eks_cluster.id
  node_role_arn      = var.node_role_arn
  node_groups        = var.node_groups
  launch_template_id = var.launch_template_id

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}


resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group_rule" "cluster_sg_rules" {
  for_each = var.cluster_sg_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.source_sg_id == null ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id
  # Use the default cluster security group created by EKS instead of custom SG
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

# OIDC Provider — required for IRSA (Auto Mode only)
data "tls_certificate" "eks_oidc" {
  count = var.enable_auto_mode ? 1 : 0
  url   = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  count           = var.enable_auto_mode ? 1 : 0
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc[0].certificates[0].sha1_fingerprint]

  tags = merge({ Name = "${var.cluster_name}-oidc-provider" }, local.common_tags)
}

# Generic IRSA roles — one per addon that has irsa_role_name set
resource "aws_iam_role" "addon_irsa_roles" {
  for_each = local.irsa_addons
  name     = each.value.irsa_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc[0].arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks_oidc[0].url, "https://", "")}:sub" = "system:serviceaccount:${each.value.service_account_namespace}:${each.value.service_account_name}"
          "${replace(aws_iam_openid_connect_provider.eks_oidc[0].url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge({ Name = each.value.irsa_role_name }, local.common_tags)
}

resource "aws_iam_role_policy_attachment" "addon_irsa_policies" {
  for_each = {
    for pair in flatten([
      for addon_name, addon in local.irsa_addons : [
        for policy_arn in addon.irsa_policy_arns : {
          key        = "${addon_name}__${policy_arn}"
          role_name  = addon.irsa_role_name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  policy_arn = each.value.policy_arn
  role       = each.value.role_name

  depends_on = [aws_iam_role.addon_irsa_roles]
}

# Auto-resolve default addon version for addons where version is not specified
data "aws_eks_addon_version" "default" {
  for_each           = local.addons_needing_version
  addon_name         = each.key
  kubernetes_version = var.eks_cluster_version
  most_recent        = false # false = default version for the k8s version
}

resource "aws_eks_addon" "addons" {
  count                = length(var.eks_addons)
  cluster_name         = aws_eks_cluster.eks_cluster.name
  addon_name           = var.eks_addons[count.index].name
  addon_version        = var.eks_addons[count.index].version != null ? var.eks_addons[count.index].version : data.aws_eks_addon_version.default[var.eks_addons[count.index].name].version
  configuration_values = var.eks_addons[count.index].configuration_values
  service_account_role_arn = (
    var.eks_addons[count.index].irsa_role_name != null &&
    var.enable_auto_mode &&
    contains(keys(aws_iam_role.addon_irsa_roles), var.eks_addons[count.index].name)
  ) ? aws_iam_role.addon_irsa_roles[var.eks_addons[count.index].name].arn : null

  tags = merge({
    Name = "${var.cluster_name}-${var.eks_addons[count.index].name}-addon"
  }, local.common_tags)

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.addon_irsa_policies,
  ]

  timeouts {
    create = "30m"
    update = "30m"
    delete = "20m"
  }
}

resource "aws_eks_access_entry" "sso_role" {
  for_each      = var.aws_sso_role_arn != null ? { "sso" = var.aws_sso_role_arn } : {}
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  type          = var.aws_sso_access_entry_type
}

resource "aws_eks_access_policy_association" "sso_role_policy" {
  for_each      = var.aws_sso_role_arn != null && var.aws_sso_access_entry_type == "STANDARD" ? { "sso" = var.aws_sso_role_arn } : {}
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  policy_arn    = var.access_entries_policy_arn

  access_scope {
    type       = var.aws_sso_access_scope_type
    namespaces = var.aws_sso_access_scope_type == "namespace" ? var.aws_sso_access_scope_namespaces : null
  }
}

# IAM roles granted cluster access via access_entries variable
resource "aws_eks_access_entry" "additional" {
  for_each      = var.access_entries
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value.principal_arn
  type          = each.value.type
}

resource "aws_eks_access_policy_association" "additional_policy" {
  for_each = {
    for pair in flatten([
      for entry_key, entry in var.access_entries : [
        for policy_arn in entry.policy_arns : {
          key                     = "${entry_key}__${policy_arn}"
          principal_arn           = entry.principal_arn
          policy_arn              = policy_arn
          access_scope_type       = entry.access_scope_type
          access_scope_namespaces = entry.access_scope_namespaces
        }
      ]
    ]) : pair.key => pair
  }

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope_type
    namespaces = each.value.access_scope_type == "namespace" ? each.value.access_scope_namespaces : null
  }

  depends_on = [aws_eks_access_entry.additional]
}
