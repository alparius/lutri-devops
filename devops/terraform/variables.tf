variable "app_version" {
  description = "App version tag."
  default     = "0.1.0"
}


variable "openweathermap_apikey" {
  description = "OpenWeatherMap API key."
}


variable "key_pair_name" {
  description = "Desired name of AWS key pair"
}

variable "public_key_path" {
  description = <<DESCRIPTION
    Path to the SSH public key to be used for authentication.
    Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "private_key_path" {
  description = <<DESCRIPTION
    Path to the SSH private key to be used for authentication.
    Used by the provisioner, to connect to the EC2 instance.
    Example: ~/.ssh/terraform
DESCRIPTION
}


variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "aws_amis" {
  description = "AWS region to AMI mappings."
  default = {
    eu-west-3 = "ami-093fa4c538885becf"
  }
}