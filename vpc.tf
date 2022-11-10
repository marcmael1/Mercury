resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

locals {
  public_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_cidr[count.index]

  tags = {
    Name = "public-subnet ${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_cidr[count.index]
  tags = {
    Name = "private-subnet${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route_table_association" "public_association" {
  count = length(local.public_cidr)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name = "private_rtb ${count.index}"
  }
}

resource "aws_route_table_association" "private_association" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}

resource "aws_eip" "eip-nat" {
  count = length(local.public_cidr)

  vpc = true

  tags = {
    "Name" = "eip-nat ${count.index}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.eip-nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "ngw ${count.index}"
  }
}
