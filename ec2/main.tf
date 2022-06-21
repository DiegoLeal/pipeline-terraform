terraform {
  required_version = "~>1.2.1"

  required_providers {
    aws = {
      version = ">= 3.50.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/* resource "aws_key_pair" "key" {
  key_name   = "awss-key"
  public_key = file("./key-aws.pub")
}  */

resource "aws_instance" "vm" {
    ami           = var.instance_ami
    instance_type = var.instance_type
    key_name      = var.key_name
    user_data = file("init-script.sh")   
    vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]
    /* depends_on = [
        aws_db_instance.rds-tf
    ] */
    associate_public_ip_address = true

    tags = {
        "Name" = "vm-terraform"
  }
}
 resource "aws_security_group" "ec2-sg" {
    name        = "ec2-sg"
    description = "ec2-sg"

ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidrs_acesso_remoto
}

ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
}

ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "ec2-sg"
    }
} 