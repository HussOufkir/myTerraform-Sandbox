terraform { 
    cloud {
    organization = "HussOufkir"
    workspaces {
      name = "Test1"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "myVpc_tf" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.myvar # it's a variable
  }
}

variable "myvar" {}