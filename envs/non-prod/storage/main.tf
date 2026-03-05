locals {
  layer = "storage"
  name  = "${var.business_unit}-${var.app_name}-${local.layer}-${var.env}"
}

module "ddb" {
  source      = "../../../modules/storage/dynamodb"
  table_name  = "${local.name}-ddb"
  hash_key    = "pk"
  enable_pitr = false

  tags = merge(var.tags, {
    business_unit = var.business_unit
    app          = var.app_name
    env          = var.env
    layer        = local.layer
    # costcenter  = "1111"
  })
}#