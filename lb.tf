
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IGW"
  }
}

# Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Route-Table"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Public Subnet A
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET-A"
  }
}

# Public Subnet B
resource "aws_subnet" "my_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.128/26"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET-B"
  }
}

# Associate both subnets with the route table
resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.my_subnet_b.id
  route_table_id = aws_route_table.my_route_table.id
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow public HTTP traffic to ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow HTTP from ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance A
resource "aws_instance" "my_instance_a" {
  ami                         = "ami-0c7632fb77f35db43"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")

  tags = {
    Name = "Server-A"
  }
}

# EC2 Instance B
resource "aws_instance" "my_instance_b" {
  ami                         = "ami-0c7632fb77f35db43"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")

  tags = {
    Name = "Server-B"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "my_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

# Register EC2 instances as targets
resource "aws_lb_target_group_attachment" "server_a" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.my_instance_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "server_b" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.my_instance_b.id
  port             = 80
}

# Application Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.my_subnet.id,
    aws_subnet.my_subnet_b.id
  ]

  tags = {
    Name = "MyLoadBalancer"
  }

  depends_on = [
    aws_route.internet_route,
    aws_route_table_association.subnet_a,
    aws_route_table_association.subnet_b
  ]
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.my_lb.dns_name
}
