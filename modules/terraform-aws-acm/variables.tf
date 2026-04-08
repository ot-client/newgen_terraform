variable "certificate_arns" {
  type        = list(string)
  description = "List of ACM certificate ARNs provided by the client to attach to ALB"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to propagate (used in outputs/locals for reference)"
}
