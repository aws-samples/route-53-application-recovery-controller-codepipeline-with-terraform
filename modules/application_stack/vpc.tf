# ---------------------------------------------------------------------------------------------------------------------
# NETWORK DETAILS
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.stack}-VPC"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERNET GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.stack}-IGW"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ELASTIC IP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_nat_gateway" "nat" {
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  allocation_id = "${aws_eip.eip.id}"
  tags = {
    Name = "${var.stack}-NatGateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)}"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.stack}-PublicSubnet-${count.index + 1}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.stack}-PrivateSubnet-${count.index + 1}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack}-PrivateRouteTable"
  }
  
}

# ---------------------------------------------------------------------------------------------------------------------
# PUBLIC ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack}-PublicRouteTable"
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE FOR PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public-route-table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  
  timeouts {
    create = "5m"
    delete = "5m"
  }
  
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE FOR PRIVATE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private-route-table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
  
  depends_on = [aws_nat_gateway.nat]
  
  timeouts {
    create = "5m"
    delete = "5m"
  }
  
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  count             = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "private" {
  count             = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}
