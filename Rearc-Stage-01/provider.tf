variable "aws_region" {
  description = "aws region for my deployment"
  type        = string
  default = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}