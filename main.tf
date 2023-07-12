locals {
  tags = {
    Application = "Chain Profile VPC"
    Environment = "Dev"
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_vpc" "chainprofile_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = local.tags
}

resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.chainprofile_vpc.id
  count             = length(var.public_subnet_cidrs)
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.tags, { "Name" = "Public Subnet ${count.index}" })
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.chainprofile_vpc.id
  count             = length(var.private_subnet_cidrs)
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]


  tags = merge(local.tags, { "Name" = "Private Subnet ${count.index}" })
}

resource "aws_internet_gateway" "chainprofile_igw" {
  vpc_id = aws_vpc.chainprofile_vpc.id

  tags = merge(local.tags, { "Name" = "Chain Profile VPC IGW" })
}


resource "aws_route_table" "public_access_route_table" {
  vpc_id = aws_vpc.chainprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chainprofile_igw.id
  }

  tags = merge(local.tags, { "Name" = "Chain Profile Public Access Route Table" })
}


resource "aws_route_table_association" "public_access_route_table_association" {
  route_table_id = aws_route_table.public_access_route_table.id

  count     = length(aws_subnet.public_subnets)
  subnet_id = aws_subnet.public_subnets[count.index].id
}
