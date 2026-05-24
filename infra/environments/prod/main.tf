# Main entry point for prod environment

locals {
  environment_name = "prod"
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}

module "cognito" {
  source      = "../../modules/cognito"
  environment = var.environment
}
