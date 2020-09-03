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


# ██████   ██████  ██      ██  ██████ ██    ██ 
# ██   ██ ██    ██ ██      ██ ██       ██  ██  
# ██████  ██    ██ ██      ██ ██        ████   
# ██      ██    ██ ██      ██ ██         ██    
# ██       ██████  ███████ ██  ██████    ██    

### declarations moved to the 'iam-stuff' subfolder for separate handling
### bug: https://github.com/serverless/examples/issues/279

data "aws_iam_role" "lambda_role" {
  name = "csalpi-tf-lambda-role"
}


# ██       █████  ███    ███ ██████  ██████   █████ 
# ██      ██   ██ ████  ████ ██   ██ ██   ██ ██   ██
# ██      ███████ ██ ████ ██ ██████  ██   ██ ███████
# ██      ██   ██ ██  ██  ██ ██   ██ ██   ██ ██   ██
# ███████ ██   ██ ██      ██ ██████  ██████  ██   ██

### public lambda function, gonna have api gateway
resource "aws_lambda_function" "public_lambda" {
  function_name = "csalpi_tf_public_lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "v${var.app_version}/public_lambda.zip"

  handler = "index.handler" # handler file and function
  runtime = "nodejs10.x"

  role = data.aws_iam_role.lambda_role.arn # "arn:aws:iam::132240640376:role/csalpi-tf-lambda-role" # aws_iam_role.lambda_role.arn

  environment {
    variables = {
      OPENWEATHERMAP_APIKEY = var.openweathermap_apikey
    }
  }

  depends_on = [aws_s3_bucket_object.file_upload_public]
}

### private lambda function, no api gateway for this
resource "aws_lambda_function" "private_lambda" {
  function_name = "csalpi_tf_private_lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "v${var.app_version}/private_lambda.zip"

  handler = "lambda_function.lambda_handler" # handler file and function
  runtime = "python3.6"

  role = data.aws_iam_role.lambda_role.arn # "arn:aws:iam::132240640376:role/csalpi-tf-lambda-role" # aws_iam_role.lambda_role.arn

  depends_on = [aws_s3_bucket_object.file_upload_private]
}


# ██████   ██████  ███████ ████████ 
# ██   ██ ██    ██ ██         ██    
# ██████  ██    ██ ███████    ██    
# ██      ██    ██      ██    ██    
# ██       ██████  ███████    ██    

### replace lambda URL in the deployable index.html
resource "null_resource" "insert_lambdalink" {
  provisioner "local-exec" {
    command = "sed -i -r 's#https:\\/\\/[a-z0-9\\.\\-]*\\/default\\/\\{myparam\\}\\?place#${module.apigateway_with_cors.lambda_url}?place#' ./application/website/index.html"
  }
}


#  █████  ██████  ██      ██████   █████  ████████ ███████ ██     ██  █████  ██    ██ 
# ██   ██ ██   ██ ██     ██       ██   ██    ██    ██      ██     ██ ██   ██  ██  ██  
# ███████ ██████  ██     ██   ███ ███████    ██    █████   ██  █  ██ ███████   ████   
# ██   ██ ██      ██     ██    ██ ██   ██    ██    ██      ██ ███ ██ ██   ██    ██    
# ██   ██ ██      ██      ██████  ██   ██    ██    ███████  ███ ███  ██   ██    ██    

module "apigateway_with_cors" {
  source  = "alparius/apigateway-with-cors/aws"
  version = "0.3.1"

  lambda_function_name = aws_lambda_function.public_lambda.function_name
  lambda_invoke_arn    = aws_lambda_function.public_lambda.invoke_arn
  path_part            = "{myparam}"
  # static - no much sense,  when not needed
  # {myparam} - catch one variable
  # {allthestuff+} - catch anything, even something like '/users/1234/orders/2'

  request_parameters = {
    "method.request.querystring.place" = true,
    "method.request.path.myparam"      = true,
  }
  request_templates = {
    "application/json" = <<EOF
    {
      "place" : "$input.params('place')",
      "myparam" : "$input.params('myparam')"
    }
    EOF
  }
}

# ### the gateway itself
# resource "aws_api_gateway_rest_api" "meteo_gw" {
#   name        = "csalpi_tf_meteo"
#   description = "csalpi, terraform, lambda, meteo"
# }

# ### permission to invoke lambdas
# resource "aws_lambda_permission" "apigw_access_lambda" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.public_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#
#   # The "/*/*" portion grants access from any method on any resource within the API Gateway REST API.
#   source_arn = "${aws_api_gateway_rest_api.meteo_gw.execution_arn}/*/*"
# }

# ### api route, mapping .../meteo
# resource "aws_api_gateway_resource" "meteo_proxy" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   parent_id   = aws_api_gateway_rest_api.meteo_gw.root_resource_id
#   path_part   = "meteo"
# }

# ### connecting the api gateway with the internet
# resource "aws_api_gateway_method" "meteo" {
#   rest_api_id   = aws_api_gateway_rest_api.meteo_gw.id
#   resource_id   = aws_api_gateway_resource.meteo_proxy.id
#   http_method   = "GET"
#   authorization = "NONE"
#
#   request_parameters = { "method.request.querystring.place" = true }
# }

# ### default 'OK' response
# resource "aws_api_gateway_method_response" "meteo_200" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   resource_id = aws_api_gateway_resource.meteo_proxy.id
#   http_method = aws_api_gateway_method.meteo.http_method
#   status_code = "200"
#
#   response_models = {
#     "application/json" = "Empty"
#   }
#
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin" = true
#   }
# }

# ### connecting the api gateway with the lambda
# resource "aws_api_gateway_integration" "meteo_lambda" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   resource_id = aws_api_gateway_method.meteo.resource_id
#   http_method = aws_api_gateway_method.meteo.http_method
#
#   integration_http_method = "POST"
#   type                    = "AWS"
#   uri                     = aws_lambda_function.public_lambda.invoke_arn
#
#   request_templates = {
#     "application/json" = <<EOF
#     {
#       "place" : "$input.params('place')"
#     }
#     EOF
#   }
# }

# ### integration response
# resource "aws_api_gateway_integration_response" "method_integration_200" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   resource_id = aws_api_gateway_resource.meteo_proxy.id
#   http_method = aws_api_gateway_method.meteo.http_method
#   status_code = aws_api_gateway_method_response.meteo_200.status_code
#
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#   }
#
#   depends_on = [
#     aws_api_gateway_method_response.meteo_200,
#     aws_api_gateway_integration.meteo_lambda
#   ]
# }

### adding OPTIONS to the api gateway
# module "cors" {
#   source  = "squidfunk/api-gateway-enable-cors/aws"
#   version = "0.3.1"
#
#   api_id          = aws_api_gateway_rest_api.meteo_gw.id
#   api_resource_id = aws_api_gateway_method.meteo.resource_id
# }

# ## deploying, needs taint to re-deploy
# resource "aws_api_gateway_deployment" "meteo_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   stage_name = "default"
#
#   depends_on = [aws_api_gateway_integration.meteo_lambda]
# }


# ### protection against spam
# ### ! needs some 'depends_on's

# resource "aws_api_gateway_stage" "meteo_stage" {
#   stage_name = aws_api_gateway_deployment.meteo_deployment.stage_name
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   deployment_id = aws_api_gateway_deployment.meteo_deployment.id
# }

# resource "aws_api_gateway_method_settings" "meteo_settings" {
#   rest_api_id = aws_api_gateway_rest_api.meteo_gw.id
#   stage_name = aws_api_gateway_stage.meteo_stage.stage_name
#   method_path = "*/*"
#
#   settings {
#     throttling_rate_limit = 5
#     throttling_burst_limit = 10
#   }
# }
