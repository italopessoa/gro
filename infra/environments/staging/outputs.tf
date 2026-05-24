output "environment" {
  value       = var.environment
  description = "The deployment environment name"
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region"
}

output "cognito_user_pool_id" {
  value       = module.cognito.user_pool_id
  description = "The ID of the Cognito User Pool"
}

output "cognito_client_id" {
  value       = module.cognito.client_id
  description = "The ID of the Cognito User Pool Client"
}

output "api_gateway_rest_api_id" {
  value       = module.api_gateway.rest_api_id
  description = "The ID of the API Gateway"
}

output "api_gateway_invoke_url" {
  value       = module.api_gateway.invoke_url
  description = "The URL to invoke the REST API Gateway stage"
}

