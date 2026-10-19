variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
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
  description = "Map of security group rules for the EKS cluster SG. Set exactly one of cidr_blocks / source_sg_id per rule."
  type = map(object({
    type         = string
    from_port    = number
    to_port      = number
    protocol     = string
    description  = optional(string)
    cidr_blocks  = optional(list(string))
    source_sg_id = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.cluster_sg_rules) : contains(["ingress", "egress"], r.type)])
    error_message = "cluster_sg_rules[*].type must be 'ingress' or 'egress'."
  }

  validation {
    condition     = alltrue([for r in values(var.cluster_sg_rules) : (r.cidr_blocks != null) != (r.source_sg_id != null)])
    error_message = "Each cluster_sg_rules entry must set exactly one of cidr_blocks or source_sg_id."
  }
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
  description = <<-EOT
    Map of EKS access entries (key = logical name).
      principal_arn     - IAM role/user ARN
      type              - STANDARD | EC2 | EC2_LINUX | EC2_WINDOWS | FARGATE_LINUX | HYBRID_LINUX
      user_name         - optional, STANDARD only
      kubernetes_groups - optional, STANDARD only (RBAC groups)
      policies          - map of access policy associations (STANDARD / EC2 only):
                            policy     = AmazonEKSAdminPolicy | AmazonEKSClusterAdminPolicy | AmazonEKSEditPolicy | AmazonEKSViewPolicy | ... (name or full ARN)
                            scope      = cluster | namespace
                            namespaces = list of namespaces (required when scope = namespace)
  EOT
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    user_name         = optional(string)
    kubernetes_groups = optional(list(string), [])
    policies = optional(map(object({
      policy     = string
      scope      = optional(string, "cluster")
      namespaces = optional(list(string), [])
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for e in values(var.access_entries) :
      contains(["STANDARD", "EC2", "EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX"], e.type)
    ])
    error_message = "access_entries[*].type must be one of STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX, HYBRID_LINUX."
  }

  validation {
    condition = alltrue([
      for e in values(var.access_entries) :
      e.type == "STANDARD" || (e.user_name == null && length(e.kubernetes_groups) == 0)
    ])
    error_message = "user_name and kubernetes_groups can only be set on STANDARD access entries."
  }

  validation {
    condition = alltrue([
      for e in values(var.access_entries) :
      contains(["STANDARD", "EC2"], e.type) || length(e.policies) == 0
    ])
    error_message = "Access policies can only be associated with STANDARD or EC2 access entries (EC2_LINUX / EC2_WINDOWS / FARGATE_LINUX / HYBRID_LINUX get permissions automatically)."
  }

  validation {
    condition = alltrue(flatten([
      for e in values(var.access_entries) : [
        for p in values(e.policies) :
        contains(["cluster", "namespace"], p.scope) && (p.scope == "cluster" || length(p.namespaces) > 0)
      ]
    ]))
    error_message = "Policy scope must be 'cluster' or 'namespace'; namespace scope requires a non-empty namespaces list."
  }
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


variable "default_cluster_sg_rules" {
  description = <<-EOT
    Rules managed on the EKS-created default cluster security group.
    Per rule set exactly one of: cidr_block, source_sg_id, self = true.
    protocol "-1" = all traffic (ports ignored).
  EOT
  type = map(object({
    type         = string
    protocol     = string
    from_port    = optional(number)
    to_port      = optional(number)
    description  = optional(string)
    cidr_block   = optional(string)
    source_sg_id = optional(string)
    self         = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.default_cluster_sg_rules) : contains(["ingress", "egress"], r.type)])
    error_message = "default_cluster_sg_rules[*].type must be 'ingress' or 'egress'."
  }

  validation {
    condition = alltrue([
      for r in values(var.default_cluster_sg_rules) :
      length([for x in [r.cidr_block != null, r.source_sg_id != null, r.self] : x if x]) == 1
    ])
    error_message = "Each default_cluster_sg_rules entry must set exactly one of cidr_block, source_sg_id or self = true."
  }

  validation {
    condition = alltrue([
      for r in values(var.default_cluster_sg_rules) :
      r.protocol == "-1" || (r.from_port != null && r.to_port != null)
    ])
    error_message = "from_port and to_port are required unless protocol is \"-1\"."
  }
}

variable "revoke_default_cluster_sg_egress" {
  description = "Remove the EKS default allow-all egress rule from the default cluster SG (needs aws CLI where terraform runs)"
  type        = bool
  default     = true
}

variable "revoke_default_cluster_sg_ingress" {
  description = "Remove the EKS default allow-all-from-self ingress rule from the default cluster SG. Control plane <-> node traffic then depends entirely on default_cluster_sg_rules."
  type        = bool
  default     = false
}

variable "create_cluster_sg" {
  description = "Create the extra module-managed cluster SG (attached as an additional SG on the control plane) and apply cluster_sg_rules to it. Set false to manage only the EKS default cluster SG via default_cluster_sg_rules."
  type        = bool
  default     = true
}
