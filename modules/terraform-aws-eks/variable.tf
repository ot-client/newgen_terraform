variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "cluster_autoscaler" {
  description = "For Cluster Cluster Autoscalling"
  default     = true
  type        = bool
}

variable "metrics_server" {
  description = "For Metrics Server"
  default     = true
  type        = bool
}

variable "k8s-spot-termination-handler" {
  description = "For Spot Instance termination handler"
  default     = true
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
}

variable "disk_size" {
  description = "Disk size of workers"
  type        = number
  default     = 20
}

variable "scale_min_size" {
  description = "Minimum count of workers"
  type        = number
  default     = 2
}

variable "scale_max_size" {
  description = "Maximum count of workers"
  type        = number
  default     = 5
}

variable "scale_desired_size" {
  description = "Desired count of workers"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tags_only" {
  description = "A map of tags to add to EKS cluster only"
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

variable "allow_eks_cidr" {
  description = "allow eks cidr"
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "force_update_version" {
  type        = bool
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = false
}

variable "cluster_endpoint_whitelist" {
  type        = bool
  description = "For Wihtelist the cluster endpoint"
  default     = false
}

variable "cluster_endpoint_access_cidrs" {
  type        = list(string)
  description = "For list of cidr to whitelist"
  default     = []
}



variable "enabled_cluster_log_types" {
  description = "List of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name    = string
    version = string
  }))
}



variable "support_type" {
  description = "Support type for EKS"
  type        = string
}

variable access_mode {
  description = "access mode for EKS"
  type        = string
}

variable "aws_sso_role_arn" {
  description = "AWS SSO role ARN that needs access to the EKS cluster"
 type        = string
  default     = null
}

variable "access_entries" {
  description = "Map of additional IAM role ARNs to grant EKS cluster access with AmazonEKSClusterAdminPolicy"
  type        = map(string)
  default     = {}
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
    ssh_key            = string
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
