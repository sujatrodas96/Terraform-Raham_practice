provider "aws" {
  region = var.region
}

module "ec2" {
  source        = "./Modules/EC2"
  ami           = var.ami
  instance_type = var.instance_type
}

module "rds" {
  source               = "./Modules/RDS"
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
}
