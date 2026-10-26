provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "VPC"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "my_subnet" {
  depends_on = [aws_vpc.my_vpc]
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/26"
  tags = {
    Name = "SUBNET-A"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "my_subnet_b" {
  depends_on = [aws_vpc.my_vpc]
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.128/26"
  tags = {
    Name = "SUBNET-B"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "my_instance_a" {
  depends_on = [aws_subnet.my_subnet]
  ami           = "ami-0c7632fb77f35db43" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  tags = {
    Name = "Server-A"
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [tags]
  }
}

resource "aws_instance" "my_instance_b" {
  depends_on = [aws_subnet.my_subnet_b]
  ami           = "ami-0c7632fb77f35db43"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_b.id
  tags = {
    Name = "Server-B"
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [tags]
  }
}
