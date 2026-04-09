variable "certificates" {
  description = "List of certificates to import into ACM. Each object needs certificate_body and private_key. certificate_chain is optional."
  type = list(object({
    certificate_body  = string
    private_key       = string
    certificate_chain = optional(string)
  }))
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to imported ACM certificates"
}
