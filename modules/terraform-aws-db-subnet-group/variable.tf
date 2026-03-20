variable "name" {
  description = "Name of the DB Subnet Group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "tags" {
  description = "Tags for DB subnet group"
  type        = map(string)
}
