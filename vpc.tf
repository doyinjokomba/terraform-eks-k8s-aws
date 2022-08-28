
#  VPC
resource "aws_vpc" "doyintestprojvpc" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "doyinterraform-eks-node",
    "kubernetes.io/cluster/doyinterraform-eks" = "shared",
  })
}

#  Subnets
resource "aws_subnet" "doyintestprojsn" {
  count = 2

  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.doyintestprojvpc.id

  tags = tomap({
    "Name"                                      = "doyinterraform-eks-node",
    "kubernetes.io/cluster/doyinterraform-eks" = "shared",
  })
}

#  Internet Gateway
resource "aws_internet_gateway" "doyintestprojig" {
  vpc_id = aws_vpc.doyintestprojvpc.id

  tags = {
    Name = "terraform-eks-doyin"
  }
}

#  Route Table
resource "aws_route_table" "doyintestprojrt" {
  vpc_id = aws_vpc.doyintestprojvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.doyintestprojig.id
  }
}


resource "aws_route_table_association" "doyintestprojrta" {
  count = 2

  subnet_id      = aws_subnet.doyintestprojsn.*.id[count.index]
  route_table_id = aws_route_table.doyintestprojrt.id
}

