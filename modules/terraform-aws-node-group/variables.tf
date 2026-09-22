variable "node_groups" {
  description = "Parameters required for creating node group"
  type = map(object({
    subnets                     = list(string)
    instance_type                = list(string)
    disk_size                    = number
    desired_capacity              = number
    max_capacity                  = number
    min_capacity                  = number
    security_group_ids            = list(string)
    labels                         = map(string)
    capacity_type                  = string
    ami_type                       = string
    taints                         = optional(any, {})
    launch_template_id             = string   # moved inside — per node group
    node_role_arn                  = string   # moved inside — per node group
  }))
}

variable "cluster_name" {
  description = "Name of parent cluster"
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

# node_role_arn aur launch_template_id top-level se hata diye — ab node_groups map ke andar per-entry hain