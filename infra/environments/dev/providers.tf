terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "pgr-mental-tfstate-dev"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pgr-mental-tflocks-dev"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "pgr-mental"
      ManagedBy   = "terraform"
    }
  }
}
