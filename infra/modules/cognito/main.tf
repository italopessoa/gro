resource "aws_cognito_user_pool" "pool" {
  name = "pgr-mental-user-pool-${var.environment}"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "tenantId"
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "role"
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  dynamic "lambda_config" {
    for_each = var.pre_token_generation_lambda_arn != null ? [1] : []
    content {
      pre_token_generation = var.pre_token_generation_lambda_arn
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "pgr-mental-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_cognito_user_group" "admin" {
  name         = "ADMIN"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Tenant Administrators"
}

resource "aws_cognito_user_group" "safety_tech" {
  name         = "SAFETY_TECH"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Safety Technicians"
}

resource "aws_cognito_user_group" "specialist" {
  name         = "SPECIALIST"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Mental Health Specialists"
}

resource "aws_cognito_user_group" "viewer" {
  name         = "VIEWER"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "View Only Users"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "pgr-mental-${var.environment}-${var.environment == "prod" ? "production" : "nonprod"}"
  user_pool_id = aws_cognito_user_pool.pool.id
}
