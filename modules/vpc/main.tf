
resource "aws_vpc" "demo" {
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    cidr_block = var.vpc_cidr
    tags = {
      Name = "my_vpc"
      env = "dev"
    }
}

output "vpc_id" {
  value = aws_vpc.demo.id
}

# It gives list of available az's in current region

data "aws_availability_zones" "available" {
  state = "available"
}

# It prints output of data src in cli

output "list_of_az" {
  value = data.aws_availability_zones.available[*].names
}

# Creates Public subnet on each az

resource "aws_subnet" "public_subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "10.2.${count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-PublicSubnet-${1+count.index}"
  }
}
    

# Creates Private subnet on each az

resource "aws_subnet" "private_subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "10.2.${10+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.app_name}-PrivateSubnet-${1+count.index}"
  }
}

# Creates IGW and attach to vpc

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "demo-igw"
  }
}


resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
   }
  tags = {
   Name = "Public-RT"
  }
 }

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  vpc = true
}


resource "aws_nat_gateway" "NAT_GATEWAY" {

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public_subnet[0].id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }
  tags = {
    Name = "Private-RT"
   }
  }

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}


