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
  region = var.aws_region
}

resource "aws_key_pair" "key" {
  key_name = "aws-key"
  public_key = var.aws_pub_key
}

resource "aws_instance" "web" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.key.key_name
  user_data     = file("init-script.sh")

  vpc_security_group_ids = ["${aws_security_group.tf-sg.id}"]
  depends_on = [
    aws_db_instance.rds-tf
  ]
  associate_public_ip_address = true

  tags = {
    "Name" = "web-terraform"
  }
}
resource "aws_security_group" "tf-sg" {
  name        = "tf-sg"
  description = "tf-sg"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
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
    Name = "tf-sg"
  }
}

module "ec2" {
  source = "./ec2"

  aws_region    = "us-east-1"
  instance_ami  = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  key_name      = "terraform"
}

resource "aws_db_instance" "rds-tf" {
  allocated_storage      = 20
  engine                 = "postgres"
  identifier             = "tf-db"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "postgres"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = ["${aws_security_group.tf-sg.id}"]
}