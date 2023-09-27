provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "asg" {
  source = "../.."

  cluster_name = "hello-world-example-one-instance"
  min_size = 1

  subnet_ids = data.aws_subnets.default.ids
  health_check_type = "ELB"
}