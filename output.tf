# API Gateway Deployment URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.api.invoke_url
}
