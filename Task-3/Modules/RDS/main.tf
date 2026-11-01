resource "aws_db_instance" "mydb" {
  identifier = "${var.db_instance_identifier}-${terraform.workspace}"
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = var.db_parameter_group_name
  skip_final_snapshot  = true

  tags = {
    Name        = "MyRDSInstance-${terraform.workspace}"
    Environment = terraform.workspace
  }
}