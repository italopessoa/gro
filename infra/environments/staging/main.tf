# Main entry point for staging environment

locals {
  environment_name = "staging"
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}
