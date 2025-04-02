# VPC 생성
resource "aws_vpc" "elb" {
  cidr_block = "10.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ELB-VPC"
  }
}

# Subnet 생성
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.elb.id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELB-Public-SN1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.elb.id
  cidr_block              = "10.40.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELB-Public-SN2"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.elb.id
  tags = {
    Name = "ELB-IGW"
  }
}

# Route Table 생성
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.elb.id
  tags = {
    Name = "ELB-Public-RT"
  }
}

# Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "elb_internet" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Subnet에 Route Table 연결
resource "aws_route_table_association" "connect1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "connect2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group for Subnet
resource "aws_security_group" "elb_sg" {
  vpc_id = aws_vpc.elb.id
  name   = "ELB-SG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 161
    to_port     = 161
    protocol    = "udp"
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

# EC2 인스턴스
resource "aws_instance" "server1" {
  ami           = "ami-070e986143a3041b6"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.elb_sg.id]
  associate_public_ip_address = true
  key_name = "my-kp"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "<html><body><h1>My EC2 Instance: $INSTANCE_ID</h1></body></html>" > /var/www/html/index.html
  EOF 

  tags = {
    Name = "SERVER-1"
  }
}

resource "aws_instance" "server2" {
  ami           = "ami-070e986143a3041b6"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.elb_sg.id]
  associate_public_ip_address = true
  key_name = "my-kp"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "<html><body><h1>My EC2 Instance: $INSTANCE_ID</h1></body></html>" > /var/www/html/index.html
  EOF 

  tags = {
    Name = "SERVER-2"
  }
}

resource "aws_instance" "server3" {
  ami           = "ami-070e986143a3041b6"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.elb_sg.id]
  associate_public_ip_address = true
  key_name = "my-kp"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "<html><body><h1>My EC2 Instance: $INSTANCE_ID</h1></body></html>" > /var/www/html/index.html
  EOF 

  tags = {
    Name = "SERVER-3"
  }
}
