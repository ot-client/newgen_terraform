variable "vault_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "vault_sku" {
  default = "Standard"
}
variable "soft_delete_enabled" {
  default = true
}
variable "vm_policy_name" {}
variable "timezone" {
  default = "UTC"
}
variable "backup_time" {
  description = "Backup start time in HH:MM (24hr UTC), e.g. 05:00"
  default     = "05:00"
}
variable "retention_daily_count" {
  description = "Number of daily backups to retain (7 = 1 week)"
  default     = 7
}
variable "vm_ids" {
  description = "Map of vm_name => vm_resource_id to protect. Add/remove VMs here in tfvars."
  type        = map(string)
  default     = {}
}
variable "tags" {
  type    = map(string)
  default = {}
}
