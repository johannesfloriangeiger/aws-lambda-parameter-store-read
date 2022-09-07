terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Systems Manager

resource "aws_ssm_parameter" "parameter" {
  name  = "parameter"
  type  = "String"
  value = "value"
}

# Lambda

data "aws_iam_policy_document" "get-parameter" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get-parameter" {
  assume_role_policy = data.aws_iam_policy_document.get-parameter.json
}

data "aws_iam_policy_document" "get-parameter-policy" {
  statement {
    actions   = ["ssm:GetParameter"]
    effect    = "Allow"
    resources = [aws_ssm_parameter.parameter.arn]
  }
}

resource "aws_iam_policy" "get-parameter-policy" {
  policy = data.aws_iam_policy_document.get-parameter-policy.json
}

resource "aws_iam_role_policy_attachment" "get-parameter-policy" {
  role       = aws_iam_role.get-parameter.id
  policy_arn = aws_iam_policy.get-parameter-policy.arn
}

data "archive_file" "lambda-placeholder" {
  type        = "zip"
  output_path = "${path.module}/lambda-placeholder.zip"

  source {
    content  = "exports.handler = async (event) => {};"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "get-parameter" {
  function_name = "get-parameter"
  role          = aws_iam_role.get-parameter.arn
  runtime       = "nodejs12.x"
  handler       = "index.handler"
  filename      = data.archive_file.lambda-placeholder.output_path

  lifecycle {
    ignore_changes = [filename]
  }
}