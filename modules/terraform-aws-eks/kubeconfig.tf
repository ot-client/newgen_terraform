# Kubeconfig file generation is disabled.
# Client does not require a local kubeconfig file to be written to disk.
# If needed in the future, set config_output_path to a valid path and
# change count back to 1.

resource "local_file" "kubeconfig" {
  count = 0

  content              = local.kubeconfig
  filename             = coalesce(var.config_output_path, "/tmp/kubeconfig_${var.cluster_name}")
  file_permission      = "0644"
  directory_permission = "0755"
  depends_on           = [aws_eks_cluster.eks_cluster]
}
