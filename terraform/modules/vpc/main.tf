locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC
resource "aws_vpc" "keubernetes_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.keubernetes_vpc.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Public Subnet in us-east-1a
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.keubernetes_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-subnet-1a"
    Type = "Public"
  })
}

# Private Subnet in us-east-1a
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.keubernetes_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-subnet-1a"
    Type = "Private"
  })
}

# Public Subnet in us-east-1b
resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.keubernetes_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-subnet-1b"
    Type = "Public"
  })
}

# Public Subnet in us-east-1c for NAT Gateway
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.keubernetes_vpc.id
  cidr_block              = "10.0.8.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-subnet-1c"
    Type = "Public"
  })
}

# Private Subnet in us-east-1b
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.keubernetes_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-subnet-1b"
    Type = "Private"
  })
}

# Additional Private Subnet in us-east-1a
resource "aws_subnet" "private_1a_additional" {
  vpc_id            = aws_vpc.keubernetes_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-subnet-1a-additional"
    Type = "Private"
  })
}

# Additional Private Subnet in us-east-1b
resource "aws_subnet" "private_1b_additional" {
  vpc_id            = aws_vpc.keubernetes_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-subnet-1b-additional"
    Type = "Private"
  })
}

# Private Subnet in us-east-1c for Storage
resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.keubernetes_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1c"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-subnet-1c"
    Type = "Private"
  })
}

# Elastic IP for NAT Gateway in us-east-1a
resource "aws_eip" "nat_1a" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-eip-1a"
  })
}

# Elastic IP for NAT Gateway in us-east-1b
resource "aws_eip" "nat_1b" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-eip-1b"
  })
}

# Elastic IP for NAT Gateway in us-east-1c
resource "aws_eip" "nat_1c" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-eip-1c"
  })
}

# NAT Gateway in us-east-1a (public subnet)
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-gateway-1a"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway in us-east-1b (public subnet)
resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.public_1b.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-gateway-1b"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway in us-east-1c (public subnet)
resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.public_1c.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-gateway-1c"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.keubernetes_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

# Route Table Association for Public Subnet 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# Route Table Association for Public Subnet 1b
resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

# Route Table Association for Public Subnet 1c
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# Single Route Table for All Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.keubernetes_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

# Route Table Association for Private Subnet 1a
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

# Route Table Association for Private Subnet 1b
resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

# Route Table Association for Additional Private Subnet 1a
resource "aws_route_table_association" "private_1a_additional" {
  subnet_id      = aws_subnet.private_1a_additional.id
  route_table_id = aws_route_table.private.id
}

# Route Table Association for Additional Private Subnet 1b
resource "aws_route_table_association" "private_1b_additional" {
  subnet_id      = aws_subnet.private_1b_additional.id
  route_table_id = aws_route_table.private.id
}

# Route Table Association for Private Subnet 1c
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}
