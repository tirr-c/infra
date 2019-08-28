resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
}

locals {
  subnets = {
    "ap-northeast-1a" = "172.31.16.0/20",
    "ap-northeast-1c" = "172.31.0.0/20",
    "ap-northeast-1d" = "172.31.32.0/20",
  }

  private_subnets = {
    "ap-northeast-1a" = "172.31.64.0/20",
    "ap-northeast-1c" = "172.31.80.0/20",
    "ap-northeast-1d" = "172.31.96.0/20",
  }
}

resource "aws_subnet" "default" {
  for_each = local.subnets

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = true
}

resource "aws_subnet" "default_private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "Private (${each.key})"
  }
}

resource "aws_eip" "gateway" {
  vpc = true
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}

resource "aws_nat_gateway" "gateway" {
  allocation_id = aws_eip.gateway.id
  subnet_id     = aws_subnet.default["ap-northeast-1a"].id

  depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gateway.id
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.default_private[each.key].id
  route_table_id = aws_route_table.private.id
}
