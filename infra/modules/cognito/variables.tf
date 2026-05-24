variable "environment" {
  type        = string
  description = "The deployment environment name"
}

variable "project" {
  type        = string
  description = "The project name"
  default     = "pgr-mental"
}

variable "pre_token_generation_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function for Cognito Pre-Token Generation trigger"
  default     = null
}
