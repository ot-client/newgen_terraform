variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN of the existing IAM role for Lambda"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.9"
}

variable "handler" {
  type        = string
  description = "Lambda handler (filename.function_name)"
  default     = "lambda_function.lambda_handler"
}

variable "timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 900
}

variable "filename" {
  type        = string
  description = "Path to the zipped Lambda deployment package"
}

