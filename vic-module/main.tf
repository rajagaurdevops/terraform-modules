# Create a VPC with a CIDR block of 10.0.0.0/16
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"  
    }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private-subnet" {
    cidr_block = "10.0.1.0/24"  # Define the IP range for the private subnet
    vpc_id = aws_vpc.my_vpc.id  # Associate the subnet with the VPC
    tags = {
        Name = "private-subnet"  
    }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public-subnet" {
    cidr_block = "10.0.2.0/24"  # Define the IP range for the public subnet
    vpc_id     = aws_vpc.my_vpc.id  # Associate the subnet with the VPC
    map_public_ip_on_launch = true  # Enable automatic public IP assignment
    tags = {
        Name = "public-subnet"  
    }
}

# Create an Internet Gateway to enable internet access
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my_vpc.id  # Attach the Internet Gateway to the VPC
    tags = {
        Name = "my-igw"  
    }
}

# Create a Route Table for the public subnet
resource "aws_route_table" "my-rt" {
    vpc_id = aws_vpc.my_vpc.id  # Associate the route table with the VPC

    route {
        cidr_block = "0.0.0.0/0"  # Allow all outbound traffic to the internet
        gateway_id = aws_internet_gateway.my-igw.id  # Use the Internet Gateway as the target
    }

    tags = {
        Name = "my-route-table"  
    }
}

# Associate the public subnet with the route table to enable internet access
resource "aws_route_table_association" "public-sub" {
    route_table_id = aws_route_table.my-rt.id  # Specify the route table
    subnet_id      = aws_subnet.public-subnet.id  # Associate it with the public subnet
}
