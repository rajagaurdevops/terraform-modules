# provider block to specify the AWS region
provider "aws" {
  region = us-east-1
  
}

# Create a VPC with a CIDR block of xyz
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnet_cidr # Define the IP range for the private subnet

  tags = {
    Name = var.private_subnet_name
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id   # # Associate the subnet with the VPC
  cidr_block              = var.public_subnet_cidr  # Define the IP range for the public subnet
  map_public_ip_on_launch = true   # Enable automatic public IP assignment

  tags = {
    Name = var.public_subnet_name
  }
}

# Create an Internet Gateway to enable internet access
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.igw_name
  }
}

# Public route table with default route via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"  # Allow all outbound traffic to the internet
    gateway_id = aws_internet_gateway.this.id  # Use the Internet Gateway as the target
  }

  tags = {
    Name = var.route_table_name
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}
