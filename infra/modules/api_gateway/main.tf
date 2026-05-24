data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project}-${var.environment}-api"
  description = "REST API entry-point for ${var.project} - ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${var.project}-${var.environment}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [var.user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

# Optional Custom Lambda Authorizer for public routes
resource "aws_api_gateway_authorizer" "lambda" {
  count = var.lambda_authorizer_arn != null ? 1 : 0

  name                   = "${var.project}-${var.environment}-lambda-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  type                   = "TOKEN"
  authorizer_uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_authorizer_arn}/invocations"
  identity_source        = "method.request.header.Authorization"
  authorizer_credentials = var.lambda_authorizer_credentials
}

# Request Validator
resource "aws_api_gateway_request_validator" "validator" {
  name                        = "${var.project}-${var.environment}-validator"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = true
  validate_request_parameters = true
}

# CloudWatch Log Group for API Access Logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "api-gateway/${var.project}-${var.environment}-access-logs"
  retention_in_days = 7
}

# IAM Role for API Gateway CloudWatch Logs (Global/Account settings)
resource "aws_iam_role" "apigateway_cloudwatch" {
  name = "${var.project}-${var.environment}-apigateway-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_cloudwatch" {
  role       = aws_iam_role.apigateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch.arn
}

# Stage Deployment
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format          = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      error          = "$context.integrationErrorMessage"
    })
  }

  depends_on = [aws_api_gateway_account.account]
}

# Method settings for Throttling (1000 burst, 500 steady limit)
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_burst_limit = 1000
    throttling_rate_limit  = 500
  }
}

# Usage Plan (for Tenants via API Keys)
resource "aws_api_gateway_usage_plan" "tenant_plan" {
  name        = "${var.project}-${var.environment}-usage-plan"
  description = "Usage plan for ${var.environment} tenants"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  throttle_settings {
    burst_limit = 1000
    rate_limit  = 500
  }

  quota_settings {
    limit  = 100000
    offset = 0
    period = "MONTH"
  }
}

resource "aws_api_gateway_api_key" "default_key" {
  name = "${var.project}-${var.environment}-default-key"
}

resource "aws_api_gateway_usage_plan_key" "default_key_assoc" {
  key_id        = aws_api_gateway_api_key.default_key.id
  usage_plan_id = aws_api_gateway_usage_plan.tenant_plan.id
  key_type      = "API_KEY"
}

# Dummy Mock Resource & Methods for Verification and Deployment
resource "aws_api_gateway_resource" "dummy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dummy"
}

# dummy GET method
resource "aws_api_gateway_method" "dummy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.dummy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "dummy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "dummy_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "dummy_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_get.http_method
  status_code = aws_api_gateway_method_response.dummy_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"message\": \"API Gateway is working!\"}"
  }
}

# dummy OPTIONS method (CORS)
resource "aws_api_gateway_method" "dummy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.dummy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "dummy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "dummy_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "dummy_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dummy.id
  http_method = aws_api_gateway_method.dummy_options.http_method
  status_code = aws_api_gateway_method_response.dummy_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,surveyToken,X-Survey-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.dummy_options_integration
  ]
}

# API Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.dummy.id,
      aws_api_gateway_method.dummy_get.id,
      aws_api_gateway_integration.dummy_integration.id,
      aws_api_gateway_method_response.dummy_response_200.id,
      aws_api_gateway_integration_response.dummy_integration_response.id,
      aws_api_gateway_method.dummy_options.id,
      aws_api_gateway_integration.dummy_options_integration.id,
      aws_api_gateway_method_response.dummy_options_200.id,
      aws_api_gateway_integration_response.dummy_options_integration_response.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
