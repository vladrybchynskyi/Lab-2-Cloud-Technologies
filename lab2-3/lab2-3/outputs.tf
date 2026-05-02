output "courses_table_arn" {
  value = module.dynamodb_courses.table_arn
}

output "authors_table_arn" {
  value = module.dynamodb_authors.table_arn
}

output "api_url" {
  value = "${aws_api_gateway_stage.v1.invoke_url}"
}