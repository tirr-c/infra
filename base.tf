terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.9.0"
    }
  }
  required_version = "~> 0.13.3"

  backend "remote" {
    organization = "tirr-c"

    workspaces {
      name = "infra"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}
