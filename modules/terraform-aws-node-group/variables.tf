variable "node_groups" {
  description = "Paramters which are required for creating node group"
  type        = any
}

variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN for node groups"
  type        = string
}

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
}

variable "force_update_version" {
  type        = bool
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = false
}