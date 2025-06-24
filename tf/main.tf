terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  required_version = ">= 1.7.0"
  backend "s3" {
    bucket = "haitham-backend"
    key    = "tfstate.json"
    region = "us-east-1"
    # optional: dynamodb_table = "<table-name>"
  }
}

provider "aws" {
  region  = var.region
  profile = "default" # change in case you want to work with another AWS account profile
}

module "polybot_service_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "<your-vpc-name>"
  cidr = "10.0.0.0/16"

  azs             = ["<az1>", "<az2>", "..."]
  private_subnets = ["<pr-subnet-CIDR-1>", "<pr-subnet-CIDR-2>"]
  public_subnets  = ["<pub-subnet-CIDR-1>", "<pub-subnet-CIDR-2>"]

  enable_nat_gateway = false

  tags = {
    Env         = var.env
  }
}



