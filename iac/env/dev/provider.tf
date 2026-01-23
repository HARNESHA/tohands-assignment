terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
  backend "s3" {
    bucket  = " "
    key     = " "
    region  = " "
    encrypt = true
  }
}

provider "aws" {
  region                   = var.AWSRegion
  profile = var.AWSProfile != "" ? var.AWSProfile : null
}