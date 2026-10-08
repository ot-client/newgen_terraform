variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "cluster_autoscaler" {
  default = true
  type    = bool
}

variable "metrics_server" {
  default = true
  type    = bool
}

variable "k8s-spot-termination-handler" {
  default = true
  type    = bool
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "subnets" {
  description = "A list of subnets for worker nodes"
  type        = list(string)
}

variable "eks_cluster_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "config_output_path" {
  description = "Path to write the kubeconfig file; leave null to skip creating it"
  type        = string
  default     = null
}

variable "kubeconfig_name" {
  description = "Name used inside the kubeconfig; defaults to cluster_name"
  type        = string
  default     = null
}

variable "endpoint_private" {
  type    = bool
  default = true
}

variable "endpoint_public" {
  type    = bool
  default = false
}

variable "slackUrl" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "force_update_version" {
  type    = bool
  default = false
}

variable "cluster_sg_rules" {
  type = map(object({
    type         = string
    from_port    = number
    to_port      = number
    protocol     = string
    cidr_blocks  = optional(list(string))
    source_sg_id = optional(string)
  }))
  default = {}
}

variable "enabled_cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "support_type" {
  type = string
}

variable "access_mode" {
  type = string
}

variable "aws_sso_role_arn" {
  type    = string
  default = null
}

variable "access_entries" {
  type    = map(string)
  default = {}
}

variable "node_groups" {
  description = "Parameters required for creating node groups"
  type = map(object({
    subnets                     = list(string)
    instance_type                = optional(list(string))
    disk_size                    = optional(number)
    desired_capacity              = number
    max_capacity                  = number
    min_capacity                  = number
    security_group_ids            = list(string)
    labels                         = map(string)
    capacity_type                  = string
    ami_type                       = string
    taints                         = optional(any, {})
    launch_template_id             = string
    node_role_arn                  = optional(string)
    iam_node_group_role_name       = string
    node_group_managed_policies    = list(string)
  }))
  default = {}
}

variable "node_group_inline_policies" {
  type    = map(string)
  default = {}
}

variable "cluster_role_name" {
  description = "IAM role name for the EKS control plane"
  type        = string
}

variable "additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ip_family" {
  type    = string
  default = "ipv4"
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "zonal_shift_enabled" {
  type    = bool
  default = false
}
