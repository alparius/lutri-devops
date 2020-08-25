# ██    ██ ██████   ██████ 
# ██    ██ ██   ██ ██      
# ██    ██ ██████  ██      
#  ██  ██  ██      ██      
#   ████   ██       ██████

### create a vpc to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "csalpi"
  }

  depends_on = [
    aws_s3_bucket_object.file_upload_index,
    aws_s3_bucket_object.file_upload_error
  ]
}

### create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "csalpi"
  }
}

### grant the vpc internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

### create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "csalpi"
  }
}

### default security group to access the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "csalpi_tf_secgroup"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere ### no ELB, "the VPC"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # "10.0.0.0/16" ### no ELB
  }

  ### no ELB
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "csalpi"
  }
}


# ███████ ██      ██████  
# ██      ██      ██   ██ 
# █████   ██      ██████  
# ██      ██      ██   ██ 
# ███████ ███████ ██████  

# ### a security group for the ELB so it is accessible via the web
# resource "aws_security_group" "elb" {
#   name        = "csalpi_terraform_example_elb"
#   description = "Used in the terraform"
#   vpc_id      = aws_vpc.default.id

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # outbound internet access
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "csalpi"
#   }
# }

# resource "aws_elb" "web" {
#   name = "terraform-example-elb"
#   subnets         = [aws_subnet.default.id]
#   security_groups = [aws_security_group.elb.id]
#   instances       = [aws_instance.web.id]

#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   tags = {
#     Name = "csalpi"
#   }
# }


# ██ ███    ██ ███████ ████████  █████  ███    ██  ██████ ███████ 
# ██ ████   ██ ██         ██    ██   ██ ████   ██ ██      ██      
# ██ ██ ██  ██ ███████    ██    ███████ ██ ██  ██ ██      █████   
# ██ ██  ██ ██      ██    ██    ██   ██ ██  ██ ██ ██      ██      
# ██ ██   ████ ███████    ██    ██   ██ ██   ████  ██████ ███████ 

### key pair to connect to instance
resource "aws_key_pair" "auth" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

### granting role to access S3
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "csalpi-2-allow-s3-for-ec2"
}

### the instance itself
resource "aws_instance" "web" {
  instance_type = "t2.micro"

  # lookup the correct AMI based on the region we specified
  ami = var.aws_amis[var.aws_region]

  # our security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.default.id]

  # our role to allow it to access S3
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  # we're going to launch into the same subnet as our ELB. In a production environment
  # it's more common to have a separate private subnet for backend instances.
  subnet_id = aws_subnet.default.id

  tags = {
    Name = "csalpi"
  }

  # print pulic IP to file
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} > public_ip.txt"
  }

  # the name of our SSH keypair we created above
  key_name = aws_key_pair.auth.id

  # the connection block tells our provisioner how to communicate with the resource (instance)
  connection {
    type = "ssh"
    # The default username for our AMI
    user = "ec2-user"
    host = self.public_ip
    # The connection will use the local SSH agent for authentication.
    private_key = file(var.private_key_path)
  }

  # we run a remote provisioner on the instance after creating it, on port 80, by default
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl start nginx",
      "sudo aws s3 cp s3://${aws_s3_bucket.website_bucket.id}/index.html /usr/share/nginx/html/index.html",
      "sudo aws s3 cp s3://${aws_s3_bucket.website_bucket.id}/error.html /usr/share/nginx/html/404.html",
    ]
  }
}
