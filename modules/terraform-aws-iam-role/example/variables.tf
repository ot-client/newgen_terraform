### naming conventions variables
variable "env" {
  description = "name of the environment"
  type        = string
}


variable "app" {
  description = "Name of the application, For ex: network, shared, ddp etc."
  type        = string
}

variable "owner" {
  type = string
  default = "opstree"
}

variable "policies" {
  description = "A list of dictionaries defining all policies."
  type = list(object({
    name                 = string                    # Name of the policy
    path                 = string                    # Defaults to 'var.policy_path' variable is set to null
    desc                 = string                    # Defaults to 'var.policy_desc' variable is set to null
    policy_template_file = optional(string, null)    # Path to json or json.tmpl file of policy
    policy_template_vars = optional(map(string), {}) # Policy template variables {key: val, ...}
    policy_statement     = optional(string, null)    # Use incase you dont want to use template
  }))
}

# -------------------------------------------------------------------------------------------------
# Role definition
# -------------------------------------------------------------------------------------------------


variable "roles" {
  description = "A list of dictionaries defining all roles."
  type = list(object({
    name = string                        # Name of the role
    path = string                        # Defaults to 'var.role_path' variable is set to null
    desc = string                        # Defaults to 'var.role_desc' variable is set to null
   trust_policy = object({
  policy_template_file = string
  policy_template_vars = object({
    assume_type         = string           # "user" or "role"
    assume_name         = string           # name of the IAM user or role
    account_id  = optional(string) # Defaults to current account if not passed
  })
})

    policies = optional(list(string), []) # List of names of policies (must be defined in var.policies)
    inline_policies = optional(list(object({
      name                 = string                 # Name of the inline policy
      policy_template_file = optional(string, null) # Path to json or json.tmpl file of policy
      policy_template_vars = optional(map(any), {}) # Policy template variables {key: val, ...}
      policy_statement     = optional(string, null) # Use incase you dont want to use template
    })), [])
    policy_arns = optional(list(string), []) # List of existing policy ARN's
  }))
}

variable "permissions_boundaries" {
  description = "A map of strings containing ARN's of policies to attach as permissions boundaries to roles."
  type        = map(string)
  default     = {}
}


# -------------------------------------------------------------------------------------------------
# Default Policy settings
# -------------------------------------------------------------------------------------------------

variable "policy_path" {
  description = "The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure."
  type        = string
  default     = "/"
}

variable "policy_desc" {
  description = "The default description of the policy."
  type        = string
  default     = ""
}


# -------------------------------------------------------------------------------------------------
# Default Role settings
# -------------------------------------------------------------------------------------------------

variable "role_path" {
  description = "The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure."
  type        = string
  default     = "/"
}

variable "role_desc" {
  description = "The description of the role."
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds."
  type        = number
  default     = 3600 # Default to 1 hour, AWS's default value
}

variable "force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  type        = bool
  default     = null
}

#################################333333

variable "create_iam_policies" {
  type    = bool
  default = true
}

variable "create_iam_roles" {
  type    = bool
  default = true
}

variable "attach_policy_arns" {
  type    = bool
  default = true
}

variable "attach_inline_policies" {
  type    = bool
  default = true
}

