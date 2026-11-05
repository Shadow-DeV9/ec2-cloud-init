resource "aws_instance" "cloud-init" {
  ami                    = "ami-0516089d963059a51"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.cloud-init-sg.id]
  user_data              = file("../cloud-init/user-data.yaml")

  tags = {
    Name = "example-instance"
  }
}

# Network resources
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_security_group" "cloud-init-sg" {
  name        = "cloud-init-sg"
  description = "Security group for cloud-init EC2 instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "cloud-init-sg"
  }
}

/*resource "aws_vpc_security_group_ingress_rule" "HTTPS" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}*/

resource "aws_vpc_security_group_ingress_rule" "HTTP" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  # This tells AWS to automatically assign public IPv4 addresses to instances launched in this subnet.
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
