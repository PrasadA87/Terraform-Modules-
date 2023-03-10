
# ---  Create a VPC ------
resource "aws_vpc" "vpc-ecs" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true 
  enable_dns_hostnames = true

    tags = {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }
} 


#------ Create internet gateway  -------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-ecs.id
  
  tags = {
    Name = "igw-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---- Create Elastic IP -----

resource "aws_eip" "nat" {
  count    = length(var.subnet-pub)
  vpc      = true
}

# --------------  NAT Gateway  ------------
resource "aws_nat_gateway" "mynat" {
  depends_on     = [aws_internet_gateway.igw]
  count          = length(var.subnet-pub) 
  allocation_id  = aws_eip.nat[count.index].id
  subnet_id      = aws_subnet.subnet-pub[count.index].id
  tags = {
    Name = "mynat-${var.environment}"
    Environment = "${var.environment}"
  }
}


# -----  Create  public and prvate subnets -------
resource "aws_subnet" "subnet-pub" {
  count        = length(var.subnet-pub)
  vpc_id       = aws_vpc.vpc-ecs.id
  cidr_block   = var.subnet-pub[count.index]
  availability_zone = var.az[count.index]
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "subnet-pub"
  }
}  

resource "aws_subnet" "subnet-priv" {
  count        = length(var.subnet-priv)
  vpc_id     = aws_vpc.vpc-ecs.id
  cidr_block = var.subnet-priv[count.index]
  availability_zone = var.az[count.index]

  tags = {
    Name = "subnet-priv"
  }
}

# ----------- Create Route tables ----------
resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.vpc-ecs.id


    route {
        cidr_block = "0.0.0.0/0"
        gateway_id =  aws_internet_gateway.igw.id 
    } 
}


resource "aws_route" "public" {
  route_table_id         = aws_route_table.public-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private-route" {
    count  = length(var.subnet-priv)
    vpc_id = aws_vpc.vpc-ecs.id
    tags = {
      Name = "private-route"
    }
}

resource "aws_route" "private" {
  count                  = length(var.subnet-priv)
  route_table_id         = aws_route_table.private-route[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.mynat[count.index].id
}


#----------  Subnet Association -----
resource "aws_route_table_association" "public" {
    count        = length(var.subnet-pub)
    subnet_id      = aws_subnet.subnet-pub[count.index].id
    route_table_id = aws_route_table.public-route.id
}


resource "aws_route_table_association" "private" {
    count          = length(var.subnet-priv)
    subnet_id      = aws_subnet.subnet-priv[count.index].id
    route_table_id = aws_route_table.private-route[count.index].id
}




