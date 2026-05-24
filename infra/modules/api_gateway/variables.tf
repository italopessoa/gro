variable "environment" {
  type        = string
  description = "The deployment environment name"
}

variable "project" {
  type        = string
  description = "The project name"
  default     = "pgr-mental"
}

variable "user_pool_arn" {
  type        = string
  description = "The ARN of the Cognito User Pool for authorization"
}

variable "lambda_authorizer_arn" {
  type        = string
  description = "The ARN of the custom Lambda Authorizer function for public routes"
  default     = null
}

variable "lambda_authorizer_credentials" {
  type        = string
  description = "The IAM role credentials for calling the Lambda Authorizer"
  default     = null
}
