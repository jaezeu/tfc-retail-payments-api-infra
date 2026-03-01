variable "business_unit" { type = string }
variable "app_name"      { type = string }
variable "layer"         { type = string } # "compute"
variable "env"           { type = string } # "prod" / "nonprod"

variable "dynamodb_table_name" { type = string }
variable "dynamodb_table_arn"  { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}