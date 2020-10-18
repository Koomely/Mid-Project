

# determine subnets (private & public)

resource "aws_subnet" "private" {
  count             = "${var.count}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.mid_project_vpc.cidr_block, 8, count.index)}"
  vpc_id            = "${aws_vpc.mid_project_vpc.id}"

  tags = {
    Name = "mid-project-private-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${var.count}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block              = "${cidrsubnet(aws_vpc.mid_project_vpc.cidr_block, 8, count.index+1)}"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.mid_project_vpc.id}"

  tags = {
    Name = "mid-project-public-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}



# ROUTING TABLES

resource "aws_route_table" "public" {
  count  = "${var.count}"
  vpc_id = "${aws_vpc.mid_project_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public-mid-project-RT-${element(aws_subnet.public.*.availability_zone, count.index)}"
  }
}

resource "aws_route_table" "private" {
  count  = "${var.count}"
  vpc_id = "${aws_vpc.mid_project_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }

  tags {
    Name = "private-mid-project-RT-${element(aws_subnet.public.*.availability_zone, count.index)}"
  }
}

# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "public" {
  count          = "${var.count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
