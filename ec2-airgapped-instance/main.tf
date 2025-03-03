terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# The number of instances required
variable "instance_count" {
  default = 1
}

# The Kay Pair name, this must be created mannualy before running
variable "key_name" {
  default = "tyler"
}

provider "aws" {
  region = "us-east-1"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access_sg"
  description = "Security group allowing inbound SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_egress" {
  name_prefix = "allow all egress"
  description = "Allow all internal traffic to EC2 instance"

  # Egress rule to allow all outbound traffic to TFC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "this" {
  count    = var.instance_count  
  domain   = "vpc"
  instance = aws_instance.example[count.index].id
}

resource "aws_instance" "example" {
  count                       = var.instance_count
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.ssh_access.id}", "${aws_security_group.allow_all_egress.id}"]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/startup.sh")

  tags = {
    Name = "DELETE_ME"
  }
}

