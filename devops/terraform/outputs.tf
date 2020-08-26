output "lambda_url" {
  value = module.apigateway_with_cors.lambda_url # aws_api_gateway_deployment.meteo_deployment.invoke_url
}

output "website_s3" {
  value = aws_s3_bucket.website_bucket.website_endpoint
}

# output "website_ec2" {
#   value = aws_elb.web.dns_name
# }

output "website_ec2_ip" {
  value = aws_instance.web.public_ip
}
