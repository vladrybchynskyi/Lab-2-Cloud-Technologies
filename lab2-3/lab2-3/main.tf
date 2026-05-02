module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  delimiter   = "-"
}

module "dynamodb_courses" {
  source     = "./modules/dynamodb"
  table_name = "${module.label.id}-courses"
  hash_key   = "id"
}

module "dynamodb_authors" {
  source     = "./modules/dynamodb"
  table_name = "${module.label.id}-authors"
  hash_key   = "id"
}

locals {
  lambdas = ["get-all-authors", "get-all-courses", "get-course", "save-course", "update-course", "delete-course"]
}

data "archive_file" "lambda_zips" {
  for_each    = toset(local.lambdas)
  type        = "zip"
  source_dir  = "${path.module}/src/${each.key}"
  output_path = "${path.module}/${each.key}.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${module.label.id}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${module.label.id}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Scan", "dynamodb:DeleteItem"]
        Effect   = "Allow"
        Resource = [
          module.dynamodb_courses.table_arn,
          module.dynamodb_authors.table_arn
        ]
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "functions" {
  for_each         = toset(local.lambdas)
  filename         = data.archive_file.lambda_zips[each.key].output_path
  function_name    = "${module.label.id}-${each.key}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zips[each.key].output_base64sha256
  runtime          = "nodejs20.x"

  environment {
    variables = {
      COURSES_TABLE = module.dynamodb_courses.table_name
      AUTHORS_TABLE = module.dynamodb_authors.table_name
    }
  }
}
