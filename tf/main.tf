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
  #profile = "default" # change in case you want to work with another AWS account profile
}


module "k8s-cluster" {
  source  = "./modules/k8s-cluster"
  env = var.env
  ami_id = var.ami_id
  key_name = var.key_name
  region = var.region
}