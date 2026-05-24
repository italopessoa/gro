output "rest_api_id" {
  value       = aws_api_gateway_rest_api.api.id
  description = "The ID of the REST API Gateway"
}

output "rest_api_arn" {
  value       = aws_api_gateway_rest_api.api.arn
  description = "The ARN of the REST API Gateway"
}

output "stage_name" {
  value       = aws_api_gateway_stage.stage.stage_name
  description = "The deployment stage name"
}

output "invoke_url" {
  value       = aws_api_gateway_stage.stage.invoke_url
  description = "The URL to invoke the REST API Gateway stage"
}

output "cognito_authorizer_id" {
  value       = aws_api_gateway_authorizer.cognito.id
  description = "The ID of the Cognito Authorizer"
}

output "lambda_authorizer_id" {
  value       = var.lambda_authorizer_arn != null ? aws_api_gateway_authorizer.lambda[0].id : null
  description = "The ID of the Lambda Authorizer"
}
