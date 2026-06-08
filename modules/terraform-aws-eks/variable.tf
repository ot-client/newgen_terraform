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
  description = "EKS provisioned control plane scaling tier. Valid values: standard, tier-xl, tier-2xl, tier-4xl, tier-8xl."
  type        = string
  default     = null

  validation {
    condition     = var.control_plane_scaling_tier == null || contains(["standard", "tier-xl", "tier-2xl", "tier-4xl", "tier-8xl"], var.control_plane_scaling_tier)
    error_message = "control_plane_scaling_tier must be one of: standard, tier-xl, tier-2xl, tier-4xl, tier-8xl."
  }
}

variable "cluster_role_arn" {
  description = "ARN of the existing IAM role for EKS cluster (created via IAM wrapper)"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the existing IAM role for EKS nodes (created via IAM wrapper)"
  type        = string
}

variable "auto_mode_node_pools" {
  description = "List of Auto Mode node pools to enable (e.g. general-purpose, system)"
  type        = list(string)
  default     = []
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
  default     = true
}
variable "endpoint_public" {
  description = "endpoint public"
  type        = bool
  default     = false
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
  default     = []
}

variable "eks_addons" {
  description = "List of EKS addons to install. Only 'name' is required — version auto-resolves from eks_cluster_version if omitted."
  type = list(object({
    name                      = string
    version                   = optional(string, null)
    configuration_values      = optional(string, null)
    irsa_role_name            = optional(string, null)
    service_account_namespace = optional(string, null)
    service_account_name      = optional(string, null)
    irsa_policy_arns          = optional(list(string), [])
  }))
  default = []
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

variable "aws_sso_access_entry_type" {
  description = "Access entry type for aws_sso_role_arn."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EC2", "EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX", "HYPERPOD_LINUX"], var.aws_sso_access_entry_type)
    error_message = "aws_sso_access_entry_type must be one of: STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX, HYBRID_LINUX, HYPERPOD_LINUX."
  }
}

variable "aws_sso_access_scope_type" {
  description = "Access scope type for aws_sso_role_arn policy association. Valid values: cluster or namespace."
  type        = string
  default     = "cluster"

  validation {
    condition     = contains(["cluster", "namespace"], var.aws_sso_access_scope_type)
    error_message = "aws_sso_access_scope_type must be either cluster or namespace."
  }
}

variable "aws_sso_access_scope_namespaces" {
  description = "Namespaces for aws_sso_role_arn policy association when aws_sso_access_scope_type is namespace."
  type        = list(string)
  default     = []
}

variable "access_entries" {
  description = "Map of IAM roles to grant EKS cluster access."
  type = map(object({
    principal_arn           = string
    policy_arns             = list(string)
    type                    = optional(string, "STANDARD")
    access_scope_type       = optional(string, "cluster")
    access_scope_namespaces = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      contains(["STANDARD", "EC2", "EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX", "HYPERPOD_LINUX"], entry.type)
    ])
    error_message = "access_entries type must be one of: STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX, HYBRID_LINUX, HYPERPOD_LINUX."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      entry.type == "STANDARD" || length(entry.policy_arns) == 0 || (
        contains(["EC2", "EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX", "HYPERPOD_LINUX"], entry.type) &&
        alltrue([for arn in entry.policy_arns : arn == "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"])
      )
    ])
    error_message = "Only STANDARD access entries can have policy_arns, except EC2-type entries which can only use AmazonEKSAutoNodePolicy."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      contains(["cluster", "namespace"], entry.access_scope_type)
    ])
    error_message = "access_entries access_scope_type must be either cluster or namespace."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      entry.access_scope_type == "namespace" || length(entry.access_scope_namespaces) == 0
    ])
    error_message = "access_scope_namespaces can only be set when access_scope_type is namespace."
  }
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


variable "enable_elastic_load_balancing" {
  description = "Enable elastic load balancing in Auto Mode"
  type        = bool
  default     = true
}

variable "enable_block_storage" {
  description = "Enable block storage in Auto Mode"
  type        = bool
  default     = true
}

variable "bootstrap_self_managed_addons" {
  description = "Enable bootstrap of self-managed addons. Set to false for Auto Mode."
  type        = bool
  default     = null
}

variable "eks_node_sg_name" {
  description = "EKS node security group name"
  type        = string
  default     = ""
}
