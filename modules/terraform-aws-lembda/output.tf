output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lembda.arn
}

output "lambda_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lembda.function_name
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lembda.invoke_arn
}
