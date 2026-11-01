variable "region" {
  type    = string
  default = "ap-south-1"
}

# ---------- EC2 ----------
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

# ---------- RDS ----------
variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_engine" {
  type    = string
  default = "mysql"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type    = string
  default = "admin"
}

# No default on purpose - pass it with: export TF_VAR_db_password='...'
variable "db_password" {
  type      = string
  sensitive = true
}
