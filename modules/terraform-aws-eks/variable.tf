variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection on the EKS cluster"
  type        = bool
  default     = false
}

variable "zonal_shift_enabled" {
  description = "Enable ARC Zonal Shift"
  type        = bool
  default     = false
}

variable "control_plane_scaling_tier" {
  description = "Control plane scaling tier (STANDARD or PREMIUM). Only applicable for Auto Mode."
  type        = string
  default     = null
}

variable "cluster_role_name" {
  description = "Override name for the cluster IAM role. Defaults to <cluster_name>-cluster-role."
  type        = string
  default     = null
}

variable "node_role_name" {
  description = "Override name for the node group IAM role. Defaults to <cluster_name>-node-role."
  type        = string
  default     = null
}

variable "auto_mode_cluster_managed_policies" {
  description = "Managed policies for cluster role when Auto Mode is enabled (must include AmazonEKSClusterPolicy)"
  type        = list(string)
  default     = []
}

variable "standard_mode_cluster_policy_arn" {
  description = "Cluster policy ARN attached in standard (non-Auto) mode"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "auto_mode_node_managed_policies" {
  description = "Managed policies for node role when Auto Mode is enabled"
  type        = list(string)
  default     = []
}

variable "auto_mode_node_pools" {
  description = "List of Auto Mode node pools to enable (e.g. general-purpose, system)"
  type        = list(string)
  default     = ["general-purpose", "system"]
}

variable "access_entries_policy_arn" {
  description = "EKS access policy ARN for SSO role (aws_sso_role_arn) only"
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "cluster_autoscaler" {
  description = "Reserved for future use — cluster autoscaler toggle"
  default     = false
  type        = bool
}

variable "metrics_server" {
  description = "Reserved for future use — metrics server toggle"
  default     = false
  type        = bool
}

variable "k8s-spot-termination-handler" {
  description = "Reserved for future use — spot termination handler toggle"
  default     = false
  type        = bool
}

variable "eks_node_group_name" {
  description = "Node group name for EKS"
  default     = "eks-node-group"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "subnets" {
  description = "A list of subnets for worker nodes"
  type        = list(string)
}

variable "eks_cluster_version" {
  description = "Kubernetes cluster version in EKS"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.eks_cluster_version))
    error_message = "eks_cluster_version must be in format like 1.35 or 1.33"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "config_output_path" {
  description = "kubeconfig output path"
  type        = string
}

variable "kubeconfig_name" {
  description = "Name of kubeconfig file"
  type        = string
}

variable "endpoint_private" {
  description = "endpoint private"
  type        = bool
  default = true
}
variable "endpoint_public" {
  description = "endpoint public"
  type        = bool
  default = false
}

variable "slackUrl" {
  description = "Slack Web hook URL"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
  default     = true
}

variable "cluster_sg_rules" {
  description = "Map of security group rules for EKS cluster SG"
  type = map(object({
    type         = string
    from_port    = number
    to_port      = number
    protocol     = string
    cidr_blocks  = optional(list(string), [])
    source_sg_id = optional(string, null)
  }))
  default = {}
}



variable "enabled_cluster_log_types" {
  description = "List of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name                      = string
    version                   = string
    configuration_values      = optional(string, null)
    irsa_role_name            = optional(string, null)  # provide to enable IRSA for this addon
    service_account_namespace = optional(string, null)  # e.g. "kube-system"
    service_account_name      = optional(string, null)  # e.g. "ebs-csi-controller-sa"
    irsa_policy_arns          = optional(list(string), []) # policies to attach to IRSA role
  }))
}



variable "support_type" {
  description = "Support type for EKS — STANDARD or EXTENDED"
  type        = string
  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "support_type must be STANDARD or EXTENDED"
  }
}

variable "access_mode" {
  description = "Cluster authentication mode"
  type        = string
  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP", "CONFIG_MAP"], var.access_mode)
    error_message = "access_mode must be API, API_AND_CONFIG_MAP, or CONFIG_MAP"
  }
}

variable "aws_sso_role_arn" {
  description = "AWS SSO role ARN for EKS cluster access — set null if using access_entries instead"
  type        = string
  default     = null
}

variable "access_entries" {
  description = "Map of IAM roles to grant EKS cluster access — each with principal_arn and list of policy_arns"
  type = map(object({
    principal_arn = string
    policy_arns   = list(string)
  }))
  default = {}
}

variable "node_groups" {
  description = "Parameters required for creating node groups"
  type = map(object({
    subnets            = list(string)
    instance_type      = list(string)
    disk_size          = number
    desired_capacity   = number
    max_capacity       = number
    min_capacity       = number
    security_group_ids = list(string)
    labels             = map(string)
    capacity_type      = string
    ami_type           = string
    taints             = optional(any, {})
  }))
  default = {}
}

variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
  default     = null
}

variable "node_group_managed_policies" {
  description = "List of AWS managed policy ARNs to attach to node group role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

variable "node_group_inline_policies" {
  description = "Map of inline policy names to policy JSON documents for node group role"
  type        = map(string)
  default     = {}
}


variable "eks_node_sg_name" {
  description = "EKS node security group name"
  type        = string
  default     = ""
}
