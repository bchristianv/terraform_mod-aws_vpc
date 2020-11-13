# Test VPC

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>2.70"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../"

  aws_region = "us-west-2"

  az_private_subnets = { a = { sbits = 8, net = 1 }, b = { sbits = 8, net = 3 } }
  az_public_subnets  = { a = { sbits = 8, net = 2 }, b = { sbits = 8, net = 4 } }

  internal_dns_domainname = "test.int"

  cidr = "10.0.0.0/16"
  name = "Test"
}
