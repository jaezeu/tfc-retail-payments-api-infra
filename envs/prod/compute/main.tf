locals {
  layer = "compute"
}

module "api" {
  source = "../../../modules/compute/lambda-apigw"

  business_unit = var.business_unit
  app_name      = var.app_name
  layer         = local.layer
  env           = var.env

  dynamodb_table_name = data.tfe_outputs.prod_storage.values.dynamodb_table_name
  dynamodb_table_arn  = data.tfe_outputs.prod_storage.values.dynamodb_table_arn

  tags = merge(var.tags, {
    business_unit = var.business_unit
    app           = var.app_name
    env           = var.env
    layer         = local.layer
  })
}