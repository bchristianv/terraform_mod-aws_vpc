# Example VPC

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
  source  = "github.com/bchristianv/terraform_mod-aws_vpc?ref=1.0.2"

  aws_region = "us-west-2"

  az_private_subnets = { a = { sbits = 8, net = 1 }, b = { sbits = 8, net = 3 } }
  az_public_subnets  = { a = { sbits = 8, net = 2 }, b = { sbits = 8, net = 4 } }

  internal_dns_domainname = "example.int"

  cidr = "10.0.0.0/8"
  name = "Example"
}

resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
