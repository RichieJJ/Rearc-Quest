resource "aws_vpc" "rearc-vpc" {
  cidr_block = "10.100.0.0/16"

  tags = {
    "Name" = "rearc-vpc"
  }
}

data "aws_availability_zones" "rearc-available-zones" {
  state = "available"
}

resource "aws_subnet" "rearc-subnet-1" {
  vpc_id            = aws_vpc.rearc-vpc.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = data.aws_availability_zones.rearc-available-zones.names[0]

  tags = {
    "Name" = "rearc-subnet-1"
  }
}

resource "aws_subnet" "rearc-subnet-2" {
  vpc_id            = aws_vpc.rearc-vpc.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = data.aws_availability_zones.rearc-available-zones.names[1]

  tags = {
    "Name" = "rearc-subnet-2"
  }
}

resource "aws_internet_gateway" "rearc-internet-gateway" {
  vpc_id = aws_vpc.rearc-vpc.id
}

resource "aws_default_route_table" "rearc-route-table" {

  default_route_table_id = aws_vpc.rearc-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rearc-internet-gateway.id
  }
}

