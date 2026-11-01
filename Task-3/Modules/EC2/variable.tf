variable "ami" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-0c7632fb77f35db43"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t3.micro"
}