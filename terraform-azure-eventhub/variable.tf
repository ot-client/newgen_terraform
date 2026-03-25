variable "namespace_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "sku" {
  default = "Standard"
}
variable "capacity" {
  default = 1
}
variable "local_authentication_enabled" {
  default = true
}
variable "eventhub_name" {}
variable "partition_count" {
  default = 2
}
variable "message_retention" {
  default = 1
}
variable "subnet_id" {
  default = null
}
variable "tags" {
  type = map(string)
}
