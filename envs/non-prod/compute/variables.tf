variable "business_unit" {
  type    = string
  default = "retail"
}

variable "app_name" {
  type    = string
  default = "payments-api"
}

variable "env" {
  type    = string
  default = "nonprod"
}

variable "tags" {
  type = map(string)
  default = {
    owner = "personal-poc"
  }
}