variable "db_instance_identifier" {
  description = "The RDS instance identifier"
  type        = string
  default     = "my-rds-instance"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp3"
}

variable "db_engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with the instance"
  type        = string
  default     = "default.mysql8.0"
}