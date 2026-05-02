# RESTAPI
resource "aws_api_gateway_rest_api" "api" {
  name = "${module.label.id}-course-api"
}

resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "courses"
}

resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "authors"
}

# CORS Modules
module "cors_courses" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api     = aws_api_gateway_rest_api.api.id
  resource = aws_api_gateway_resource.courses.id
  methods = ["GET", "POST", "OPTIONS"]
}

module "cors_course_id" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api     = aws_api_gateway_rest_api.api.id
  resource = aws_api_gateway_resource.course_id.id
  methods = ["GET", "PUT", "DELETE", "OPTIONS"]
}

module "cors_authors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api     = aws_api_gateway_rest_api.api.id
  resource = aws_api_gateway_resource.authors.id
  methods = ["GET", "OPTIONS"]
}

# Methods and Integrations

# GET query for courses
resource "aws_api_gateway_method" "get_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_courses" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.functions["get-all-courses"].invoke_arn
}

# POST query for courses (w validation)
resource "aws_api_gateway_model" "course_model" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "CourseInputModel"
  content_type = "application/json"
  schema       = <<EOF
{
  "$schema": "http://json-schema.org/schema#",
  "title": "CourseInputModel",
  "type": "object",
  "properties": {
    "title": {"type": "string"},
    "authorId": {"type": "string"},
    "length": {"type": "string"},
    "category": {"type": "string"}
  },
  "required": ["title", "authorId", "length", "category"]
}
EOF
}

resource "aws_api_gateway_request_validator" "validator" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "ValidateBody"
  validate_request_body = true
}

resource "aws_api_gateway_method" "post_courses" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.courses.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.course_model.name
  }
}

resource "aws_api_gateway_integration" "post_courses" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.post_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.functions["save-course"].invoke_arn
}

# PUT query /courses/{id} (With Mapping Template)
resource "aws_api_gateway_method" "put_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_course" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.put_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.functions["update-course"].invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')",
  "title" : $input.json('$.title'),
  "authorId" : $input.json('$.authorId'),
  "length" : $input.json('$.length'),
  "category" : $input.json('$.category'),
  "watchHref" : $input.json('$.watchHref')
}
EOF
  }
}

# DELETE for /courses/{id} (w Mapping Template)
resource "aws_api_gateway_method" "delete_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_course" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.delete_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.functions["delete-course"].invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
  }
}

# GET query for authors
resource "aws_api_gateway_method" "get_authors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_authors" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.functions["get-all-authors"].invoke_arn
}

# lambda permissions
resource "aws_lambda_permission" "apigw_lambda" {
  for_each      = toset(local.lambdas)
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Deploy
resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [
    aws_api_gateway_integration.get_courses,
    aws_api_gateway_integration.post_courses,
    aws_api_gateway_integration.put_course,
    aws_api_gateway_integration.delete_course,
    aws_api_gateway_integration.get_authors
  ]
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}