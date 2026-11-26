variable "node_groups" {
  description = "Parameters required for creating node group"
  type = map(object({
    subnets            = list(string)
    instance_type      = optional(list(string))
    disk_size          = optional(number)
    desired_capacity   = number
    max_capacity       = number
    min_capacity       = number
    security_group_ids = list(string)
    labels             = map(string)
    capacity_type      = string
    ami_type           = string
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
    launch_template_id   = optional(string)
    node_role_arn        = optional(string)
    tags                 = optional(map(string), {})
    force_update_version = optional(bool, false) # true = rolling update existing nodes to new LT version on next apply
  }))
}

variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
}