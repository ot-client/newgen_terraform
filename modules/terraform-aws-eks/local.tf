locals {
  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name     = var.kubeconfig_name
    cluster_name        = var.cluster_name
    endpoint            = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    cluster_arn         = aws_eks_cluster.eks_cluster.arn
    region              = var.region
  })

  configmap_roles = [
    {
      rolearn  = aws_iam_role.node_group_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  irsa_addons = {
    for addon in var.eks_addons :
    addon.name => addon
    if addon.irsa_role_name != null && var.enable_auto_mode
  }
}
