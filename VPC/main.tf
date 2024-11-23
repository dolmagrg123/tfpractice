#Create a Custom VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/18"
  tags = {
    Name = "VPC_1"

  }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones  # Use different AZs
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "Internet_Gateway"
  }
}

resource "aws_route_table" "rt_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_1.id
}


# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones # Use different AZs
  tags = {
    Name = "private_subnet"
  }
}

#private subnet route table
resource "aws_route_table" "rt_2" {
  vpc_id = aws_vpc.vpc_1.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private_route_table"
  }
}

#private subnet route association
resource "aws_route_table_association" "assoc_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.rt_2.id
}


# Create an Elastic IP for the NAT Gateway

resource "aws_eip" "nat_eip" {
  # instance = aws_instance.web.id
  domain   = "vpc"
  tags = {
    Name = "NAT_EIP"
  }

  # depends_on = [ aws_internet_gateway.gw ]
}

# Create the NAT Gateway in the public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "NAT_Gateway"
  }
}



