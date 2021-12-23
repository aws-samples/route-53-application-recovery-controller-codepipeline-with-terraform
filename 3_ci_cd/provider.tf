# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER FOR TF CLOUD
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.57.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = var.aws_region_1
  profile = var.aws_profile
}

provider "aws" {
  alias  = "region-2"
  region  = var.aws_region_2
  profile = var.aws_profile
}