variable "diagnostic_name" {
  type = string
}

variable "target_resource_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "log_categories" {
  type = list(string)
}

variable "action_group_name" {
  type = string
}

variable "action_group_short_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "email_receivers" {
  type = list(object({
    name  = string
    email = string
  }))
  default = []
}

variable "alert_name" {
  type = string
}

variable "alert_description" {
  type = string
}

variable "scopes" {
  type = list(string)
}

variable "alert_category" {
  type = string
}

variable "operation_name" {
  type = string
}

variable "location" {
  type = string
}