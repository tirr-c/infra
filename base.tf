provider "aws" {
  version = "~> 2.23"
  region  = "ap-northeast-1"
}

provider "aws" {
  version = "~> 2.23"
  region  = "us-east-1"
  alias   = "us_east_1"
}

provider "aws" {
  version = "~> 2.23"
  region  = "us-west-2"
  alias   = "us_west_2"
}

terraform {
  required_version = "~> 0.12.6"

  backend "remote" {
    organization = "tirr-c"

    workspaces {
      name = "infra"
    }
  }
}
