terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "pgr-mental-tfstate-prod"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pgr-mental-tflocks-prod"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "prod"
      Project     = "pgr-mental"
      ManagedBy   = "terraform"
    }
  }
}
