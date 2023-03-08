provider "aws" {
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
    region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}