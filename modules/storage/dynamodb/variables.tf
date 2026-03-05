variable "table_name" {
  type = string
}

variable "hash_key" {
  type    = string
  default = "pk"
}

variable "enable_pitr" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}