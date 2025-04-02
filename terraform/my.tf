provider "aws" { }

# VPC 생성
resource "aws_vpc" "my_vpc" {
  cidr_block = "20.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Public Subnet 생성
resource "aws_subnet" "my_sub" {
  vpc_id			= aws_vpc.my_vpc.id
  cidr_block			= "20.40.1.0/24"
  availability_zone	= "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "My-Public-SN"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My-IGW"
  }
}

# Public Route Table 생성
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyPublicRT"
  }
}

# Public Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.my_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.my_sub.id
  route_table_id = aws_route_table.my_rt.id
}

# Security Group for Public Subnet
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "public-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "public_ec2" {
  ami           = "ami-070e986143a3041b6"  # Amazon Linux 2 AMI 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_sub.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name = "my-kp"
  tags = {
    Name = "MyEC2"
  }
}
