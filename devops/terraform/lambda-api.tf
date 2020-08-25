terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}


# ██████  ██    ██ ██ ██      ██████  
# ██   ██ ██    ██ ██ ██      ██   ██ 
# ██████  ██    ██ ██ ██      ██   ██ 
# ██   ██ ██    ██ ██ ██      ██   ██ 
# ██████   ██████  ██ ███████ ██████  

resource "null_resource" "zip_public" {
  provisioner "local-exec" {
    command = "(cd ./application/public-lambda/ && zip -r ../../target/public_lambda.zip .)"
  }
}

resource "null_resource" "zip_private" {
  provisioner "local-exec" {
    command = "(cd ./application/private-lambda/ && zip -r ../../target/private_lambda.zip .)"
  }
}


# ██    ██ ██████  ██       ██████   █████  ██████  
# ██    ██ ██   ██ ██      ██    ██ ██   ██ ██   ██ 
# ██    ██ ██████  ██      ██    ██ ███████ ██   ██ 
# ██    ██ ██      ██      ██    ██ ██   ██ ██   ██ 
#  ██████  ██      ███████  ██████  ██   ██ ██████  

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "csalpi-tf-bucket-lambda"
  acl    = "public-read"

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_object" "file_upload_public" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "v${var.app_version}/public_lambda.zip"
  source = "target/public_lambda.zip"

  depends_on = [null_resource.zip_public]
}

resource "aws_s3_bucket_object" "file_upload_private" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "v${var.app_version}/private_lambda.zip"
  source = "target/private_lambda.zip"

  depends_on = [null_resource.zip_private]
}


# ██       █████  ███    ███ ██████  ██████   █████  ███████ 
# ██      ██   ██ ████  ████ ██   ██ ██   ██ ██   ██ ██
# ██      ███████ ██ ████ ██ ██████  ██   ██ ███████ ███████ 
# ██      ██   ██ ██  ██  ██ ██   ██ ██   ██ ██   ██      ██ 
# ███████ ██   ██ ██      ██ ██████  ██████  ██   ██ ███████ 

# # IAM role which dictates what other AWS services the Lambda function may access.
# data "aws_iam_policy_document" "base_policy" {
#   statement {
#     sid    = ""
#     effect = "Allow"

#     principals {
#       identifiers = ["lambda.amazonaws.com"]
#       type        = "Service"
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "lambda_exec" {
#   name               = "csalpi_tf_lambda_role"
#   assume_role_policy = data.aws_iam_policy_document.base_policy.json
# }

resource "aws_lambda_function" "public_lambda" {
  function_name = "csalpi_tf_public_lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "v${var.app_version}/public_lambda.zip"

  handler = "index.handler" # handler file and function
  runtime = "nodejs10.x"

  role = "[arn]" # aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      OPENWEATHERMAP_APIKEY = var.openweathermap_apikey
    }
  }

  depends_on = [aws_s3_bucket_object.file_upload_public]
}

resource "aws_lambda_function" "private_lambda" {
  function_name = "csalpi_tf_private_lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "v${var.app_version}/private_lambda.zip"

  handler = "lambda_function.lambda_handler" # handler file and function
  runtime = "python3.6"

  role = "[arn]" # aws_iam_role.lambda_exec.arn

  depends_on = [aws_s3_bucket_object.file_upload_private]
}


#  █████  ██████  ██      ██████   █████  ████████ ███████ ██     ██  █████  ██    ██ 
# ██   ██ ██   ██ ██     ██       ██   ██    ██    ██      ██     ██ ██   ██  ██  ██  
# ███████ ██████  ██     ██   ███ ███████    ██    █████   ██  █  ██ ███████   ████   
# ██   ██ ██      ██     ██    ██ ██   ██    ██    ██      ██ ███ ██ ██   ██    ██    
# ██   ██ ██      ██      ██████  ██   ██    ██    ███████  ███ ███  ██   ██    ██                                                                                     

### the gateway itself
resource "aws_api_gateway_rest_api" "meteo_gw" {
  name        = "csalpi_tf_meteo"
  description = "csalpi, terraform, lambda, meteo"
}

### permission to invoke lambdas
resource "aws_lambda_permission" "apigw_access_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.public_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.meteo_gw.execution_arn}/*/*"
}

### api resource, mapping .../meteo
resource "aws_api_gateway_resource" "meteo_proxy" {
  rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
  parent_id   = aws_api_gateway_rest_api.meteo_gw.root_resource_id
  path_part   = "meteo"
}

### connecting the api gateway with the internet
resource "aws_api_gateway_method" "meteo" {
  rest_api_id   = aws_api_gateway_rest_api.meteo_gw.id
  resource_id   = aws_api_gateway_resource.meteo_proxy.id
  http_method   = "GET"
  authorization = "NONE"
  # request_parameters = { "method.request.querystring.place" = true }
}

### connecting the api gateway with the lambda
resource "aws_api_gateway_integration" "meteo_lambda" {
  rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
  resource_id = aws_api_gateway_method.meteo.resource_id
  http_method = aws_api_gateway_method.meteo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.public_lambda.invoke_arn

  # request_templates = {
  #   "application/json" = <<EOF
  #   {
  #     "place" : "$input.params('place')"
  #   }
  #   EOF
  # }
}

### adding OPTIONS to the api gateway
module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.1"

  api_id          = aws_api_gateway_rest_api.meteo_gw.id
  api_resource_id = aws_api_gateway_method.meteo.resource_id
}

### deploying, needs taint to re-deploy
resource "aws_api_gateway_deployment" "meteo_deployment" {
  rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
  stage_name  = "default"

  depends_on = [aws_api_gateway_integration.meteo_lambda]
}


### extra -----------------------------------------------------
### replace lambda URL in the deployable index.html
### extra -----------------------------------------------------
resource "null_resource" "insert_lambdalink" {
  provisioner "local-exec" {
    command = "sed -i -r 's#https:\\/\\/[a-z0-9\\.\\-]*\\/default\\/meteo\\?place#${aws_api_gateway_deployment.meteo_deployment.invoke_url}\\/meteo?place#' ./application/website/index.html"
  }

  depends_on = [aws_api_gateway_deployment.meteo_deployment]
}
