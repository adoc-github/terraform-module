data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = "${var.vpc_id}"
  tags = {
    Name = "app-subnet*"
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = "${var.vpc_id}"
  tags = {
    Name = "private-subnet*"
  }
}

locals {
  sandbox_id = "sb${substr( uuid() , 0 ,6)}"
}