output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "Public Subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
  description = "Private Subnet ID"
}

output "igw_id" {
  value       = aws_internet_gateway.this.id
  description = "Internet Gateway ID"
}

output "public_route_table_id" {
  value       = aws_route_table.public_rt.id
  description = "Public Route Table ID"
}
