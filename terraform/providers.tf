terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  # These tags get added to EVERY resource Terraform creates
  default_tags {
    tags = {
      Project   = "selfheal-aws-project"
      ManagedBy = "terraform"
      Owner     = "gokul"
    }
  }
}