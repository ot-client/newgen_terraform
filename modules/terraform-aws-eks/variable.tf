variable "deletion_protection" {
  description = "Enable deletion protection for EKS cluster"
  type        = bool
  default     = false
}

variable "cluster_iam_role_name" {
  description = "Name of the IAM role for EKS cluster"
  type        = string
}

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

variable "cluster_sg_rules" {
  description = "Map of security group rules for EKS cluster SG"
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
  description = "List of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name    = string
    version = optional(string, null)
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
  description = "Map of IAM role ARNs with their policy ARNs to grant EKS cluster access"
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
    labels             = optional(map(string), {})
    capacity_type      = string
    ami_type           = string
    taints             = optional(any, [])
    subnet_names       = optional(list(string), [])
    launch_template_id = string
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
