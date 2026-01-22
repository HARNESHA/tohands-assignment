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
  profile                  = var.AWSProfile
  region                   = var.AWSRegion
  shared_credentials_files = ["~/.aws/credentials"]
}