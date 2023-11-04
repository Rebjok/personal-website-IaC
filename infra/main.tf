## Lambda function
resource "aws_lambda_function" "personal-website-func" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "personal-website-func"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "func.handler"
  runtime          = "python3.11"
}

##AWS IAM Role for lambda Function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

## AWS IAM Policy for managing the personal website project role
resource "aws_iam_policy" "iam_policy_for_website_project" {

  name        = "aws_iam_policy_for_terraform_website_project_policy"
  path        = "/"
  description = "AWS IAM Policy for managing the personal website project role"
    policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
			      "dynamodb:GetItem"
          ],
          "Resource" : "arn:aws:dynamodb:*:*:table/personal-website-table"
        },
      ]
  })
}

##Attach IAM policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_website_project.arn
  
}

##Zip file for the lambda python code in lambda directory
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/func.py"
  output_path = "${path.module}/lambda/func.zip"
}

##function url fo lambda function invokation
resource "aws_lambda_function_url" "personal_website_func_url" {
  function_name      = aws_lambda_function.myfunc.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://www.reibjokothow.com","https://reibjokothow.com"]
    allow_methods     = ["GET"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}