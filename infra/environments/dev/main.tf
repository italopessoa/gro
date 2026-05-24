# Main entry point for dev environment

locals {
  environment_name = "dev"
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}
