# Main entry point for staging environment

locals {
  environment_name = "staging"
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}

module "cognito" {
  source      = "../../modules/cognito"
  environment = var.environment
}

module "api_gateway" {
  source        = "../../modules/api_gateway"
  environment   = var.environment
  user_pool_arn = module.cognito.user_pool_arn
}

