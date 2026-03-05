resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? 20 : null
  write_capacity = var.billing_mode == "PROVISIONED" ? 20 : null

  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  tags = var.tags
}