resource "aws_ec2_instance" "cloud-init" {
  ami           = "ami-0516089d963059a51"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "example-instance"
  }
}

resource "aws_security_group" "cloud-init-sg" {
  name        = "cloud-init-sg"
  description = "Security group for cloud-init EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.cloud-init-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
