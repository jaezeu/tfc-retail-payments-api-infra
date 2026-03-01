terraform {
  required_version = ">= 1.6.0"

#   cloud {
    # organization = "hcp-poc-jazeel"

    # workspaces {
    #   name = "retail-payments-api-storage-nonprod"
    # }
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}