output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "node_iam_role_arn" {
  description = "Per-node-group IAM Role ARNs"
  value       = { for k, r in data.aws_iam_role.node_group_role : k => r.arn }
}

output "cluster_iam_role_arn" {
  value = data.aws_iam_role.cluster_role.arn
}

output "node_groups_arn" {
  value = module.node_group.node_group_arn
}

output "node_groups_resources" {
  value = module.node_group.node_group_resources
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "eks_cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "module_node_group_resources" {
  value = module.node_group.node_group_resources
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}