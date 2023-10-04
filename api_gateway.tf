# Create REST API
resource "aws_api_gateway_rest_api" "api" {
  depends_on = [
    aws_lambda_function.nginx
  ]

  name        = "${var.project_name}-rest-api"
  description = "API Gateway for ${var.project_name}"
  binary_media_types = [
    "*/*"
  ]
}

# /{proxy+} resource
resource "aws_api_gateway_resource" "proxy" {
  depends_on = [
    aws_api_gateway_rest_api.api
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# ANY method for / resource
resource "aws_api_gateway_method" "root_any" {
  depends_on = [
    aws_api_gateway_rest_api.api
  ]

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# ANY method for /{proxy+} resource
resource "aws_api_gateway_method" "proxy_any" {
  depends_on = [
    aws_api_gateway_resource.proxy,
    aws_api_gateway_rest_api.api
  ]

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# ANY integration for /{proxy+} resource
resource "aws_api_gateway_integration" "proxy_integration" {
  depends_on = [
    aws_api_gateway_method.proxy_any,
    aws_api_gateway_rest_api.api
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_any.http_method

  type = "AWS_PROXY"

  integration_http_method = "POST"
  uri                     = aws_lambda_function.nginx.invoke_arn
}

# ANY integration for / resource
resource "aws_api_gateway_integration" "root_integration" {
  depends_on = [
    aws_api_gateway_method.root_any,
    aws_api_gateway_rest_api.api
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_any.http_method

  type = "AWS_PROXY"

  integration_http_method = "POST"
  uri                     = aws_lambda_function.nginx.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_integration.proxy_integration,
    aws_api_gateway_integration.root_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = "prod"
}