locals {
  # base_name is derived from the "Name" key in var.tags (set per-resource in tfvars)
  base_name = lookup(var.tags, "Name", "")

  # common_tags strips the "Name" key so each resource can set its own Name tag
  common_tags = { for k, v in var.tags : k => v if k != "Name" }
}
locals {
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
      groups = tolist(concat(
        [
          "system:bootstrappers",
          "system:nodes",
        ],
      ))
    }
  ]
}
