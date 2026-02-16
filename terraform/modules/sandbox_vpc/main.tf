resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = { Name = "${var.name_prefix}-dhcp" }
}

resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index + 6) # /28: 10.0.0.96/28 y 10.0.0.112/28
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-public-${var.azs[count.index]}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 2, count.index) # /27: 10.0.0.0/27 y 10.0.0.32/27
  availability_zone = var.azs[count.index]
  tags              = { Name = "${var.name_prefix}-private-${var.azs[count.index]}" }
}

resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 4) # /28: 10.0.0.64/28 y 10.0.0.80/28
  availability_zone = var.azs[count.index]
  tags              = { Name = "${var.name_prefix}-db-${var.azs[count.index]}" }
}

resource "aws_eip" "nat" {
  tags = { Name = "${var.name_prefix}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.name_prefix}-nat" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-rt-public" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-rt-private-${var.azs[count.index]}" }
}

resource "aws_route" "private_nat" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "db" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-rt-db-${var.azs[count.index]}" }
}

resource "aws_route" "db_nat" {
  count                  = 2
  route_table_id         = aws_route_table.db[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "db" {
  count          = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.db[*].id
  )
  tags = { Name = "${var.name_prefix}-s3-endpoint" }
}
