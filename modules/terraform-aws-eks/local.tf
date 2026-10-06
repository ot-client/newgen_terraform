locals {
  base_name   = lookup(var.tags, "Name", "")
  common_tags = { for k, v in var.tags : k => v if k != "Name" }

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name     = coalesce(var.kubeconfig_name, var.cluster_name)
    cluster_name        = var.cluster_name
    endpoint            = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    cluster_arn         = aws_eks_cluster.eks_cluster.arn
    region              = var.region
  })

  configmap_roles = [
    for ng_key, role in aws_iam_role.node_group_role : {
      rolearn  = role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
}