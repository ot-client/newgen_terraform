output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig_certificate_authority_data" {
  description = "Kubernetes SSL certificate data"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Default security group ID created by EKS for the cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_iam_role_arn" {
  description = "Node group IAM Role ARN"
  value       = aws_iam_role.node_group_role.arn
}

output "node_group_arns" {
  description = "Map of node group IDs to ARNs"
  value       = module.node_group.node_group_arn
}

output "node_group_resources" {
  description = "Map of node group IDs to resources"
  value       = module.node_group.node_group_resources
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}