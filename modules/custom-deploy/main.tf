provider "aws" {
    region = var.aws_region
}

resource "aws_security_group" "ec2-web-apache-sg" {
    name        = "ec2-web-apache-sg"
    description = "Security group for EC2 with apache hosted app"
    vpc_id = "vpc-0b4e5ae1ba2275b18"

    ingress {
      description = "Permitir SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "Permitir HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    Name = "ec2-instance-web01_SG"
  }

}

resource "aws_instance" "ec2-instance-web01" {
    ami = var.ami
    instance_type= var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.ec2-web-apache-sg.id]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.public_ip
    private_key = file("D:/Estudio/ORT/Implementacion de Soluciones Cloud/AWS_Key/labsuser.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo yum install git -y",
      "sudo git clone https://github.com/mauricioamendola/chaos-monkey-app.git /var/www/html",
      "sudo systemctl restart httpd",
    ]
  }
}

resource "aws_vpc" "test-terraform-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test-terraform-vpc"
  }
}

resource "aws_subnet" "test-terraform-subnet" {
  vpc_id                  = aws_vpc.test-terraform-vpc.id #Asociamos un recurso creado con terraform
  cidr_block              = "172.16.1.0/24"
  availability_zone       = var.AZ
  map_public_ip_on_launch = "true"
  tags = {
    Name = "test-terraform-subnet"
  }
}

resource "aws_internet_gateway" "test-terraform-ig" {
  vpc_id                  = aws_vpc.test-terraform-vpc.id
   tags = {
    Name = "test-terraform-ig"
  }
}

resource "aws_route_table" "test-terraform-rt" {
  vpc_id                  = aws_vpc.test-terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-terraform-ig.id
  }

}