provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us_west_2"
}

terraform {
  required_providers {
    aws = {
      source = "-/aws"
      version = "~> 2.70.0"
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
