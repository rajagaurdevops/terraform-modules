# -------------------------
# Create base VPC
# -------------------------
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr
}

# -------------------------
# Public subnet in AZ1
# -------------------------
resource "aws_subnet" "dev-sub1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# -------------------------
# Public subnet in AZ2
# -------------------------
resource "aws_subnet" "dev-sub2" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# -------------------------
# Internet gateway for egress
# -------------------------
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id
}

# -------------------------
# Public route table with default route via IGW
# -------------------------
resource "aws_route_table" "dev-RT" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }
}

# -------------------------
# Associate each subnet to the public route table
# -------------------------
resource "aws_route_table_association" "dev-rta1" {
  subnet_id      = aws_subnet.dev-sub1.id
  route_table_id = aws_route_table.dev-RT.id
}

resource "aws_route_table_association" "dev-rta2" {
  subnet_id      = aws_subnet.dev-sub2.id
  route_table_id = aws_route_table.dev-RT.id
}
