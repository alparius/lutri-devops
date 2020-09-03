terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

# ██████   ██████  ██      ██  ██████ ██    ██ 
# ██   ██ ██    ██ ██      ██ ██       ██  ██  
# ██████  ██    ██ ██      ██ ██        ████   
# ██      ██    ██ ██      ██ ██         ██    
# ██       ██████  ███████ ██  ██████    ██    

data "aws_caller_identity" "current_account" {}

### first create a role for lambdas
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "csalpi-tf-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

### attach log, s3 and lambda-invoke policies to the created role
data "aws_iam_policy_document" "lambda_policies" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
    ]
    resources = ["arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current_account.account_id}:function:*"]
  }
}

resource "aws_iam_role_policy" "lambda_role_policies" {
  name   = "csalpi-tf-lambda-policies"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policies.json
}