module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  delimiter   = "-"
}

module "dynamodb_table" {
  source = "./modules/dynamodb"

  table_name = module.label.id 
  hash_key   = "id"
}