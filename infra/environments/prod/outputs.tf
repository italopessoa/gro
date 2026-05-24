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
