# Create AWS Lambda Function from ECR Image
resource "aws_lambda_function" "nginx" {
  depends_on = [
    aws_ecr_repository.ecr,
    null_resource.build,
    aws_iam_role.lambda
  ]

  function_name = var.project_name
  architectures = [
    "arm64"
  ]
  package_type = "Image"
  image_uri    = "${aws_ecr_repository.ecr.repository_url}:latest"
  role         = aws_iam_role.lambda.arn
  memory_size  = 1024

  environment {
    variables = {
      RUST_LOG = "debug"
      PORT     = "8080"
    }
  }
}

# Update Lambda Image to latest with Lambda API
resource "null_resource" "post_deployment" {
  depends_on = [
    aws_lambda_function.nginx,
    null_resource.build
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    interpreter = [
      "/bin/sh",
      "-c"
    ]

    command = <<-COMMAND
        # Update Lambda Image to latest with Lambda API
        aws lambda update-function-code --function-name ${aws_lambda_function.nginx.function_name} --region ap-southeast-1 --image-uri ${aws_ecr_repository.ecr.repository_url}:latest
    COMMAND
  }
}

# Add API GW Lambda Permission
resource "aws_lambda_permission" "api_gateway" {
  depends_on = [
    aws_lambda_function.nginx,
    aws_api_gateway_deployment.api
  ]

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nginx.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}
