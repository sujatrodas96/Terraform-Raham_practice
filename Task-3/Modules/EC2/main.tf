resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name        = "ExampleInstance-${terraform.workspace}"
    Environment = terraform.workspace
  }
}