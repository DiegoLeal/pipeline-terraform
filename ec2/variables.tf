variable "aws_region" {
    type = string
    description = ""
    default = "us-east-1"
}

variable "instance_ami" {
  type        = string
  description = ""
  default     = "ami-09d56f8956ab235b3"
}

variable "instance_type" {
  type        = string
  description = ""
  default     = "t2.micro"
}

variable "key_name" {
  default = "terraform"
}

variable "cidrs_acesso_remoto" {
    type = list
    description = ""
    default = ["0.0.0.0/0"]
}