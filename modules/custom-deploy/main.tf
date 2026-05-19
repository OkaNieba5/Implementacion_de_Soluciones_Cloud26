provider "aws" {
    region = var.aws_region
}

resource "aws_security_group" "ssh-http-access" {
    name        = "ssh-http-access"
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
    Name = "ssh-http-access"
  }

}

resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  vpc_id      =  aws_vpc.practico_3tier.id

  ingress {
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
}

resource "aws_db_instance" "db-ecommerce-1" {
    allocated_storage    = 10
    db_name              = "e-commerce1"
    engine               = "mysql"
    parameter_group_name = "default:mysql5.7"
    engine_version       = "5.7.44-rd.20250103"
    instance_class       = "db.t3.micro"
    username             = "adminecommerce"
    password             = "MySecretPassword1234"
    db_subnet_group_name = "local.db_subnet_group_name"
    storage_type         = "gp2"
    multi_az = "false"
    skip_final_snapshot  = true
  
}

resource "aws_instance" "webapp-server01" {
    ami = var.ami
    instance_type= var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.ssh-http-access.id]
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
      "sudo git clone https://github.com/mauricioamendola/simple-ecomme.git /var/www/html",
      "sudo systemctl restart httpd",
      "sudo yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm",
      "sudo yum install -y mysql-community-server",
      "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
      "sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm",
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --enable remi-php56",
      "sudo yum install -y php php-mcrypt php-cli php-gd",
      "sudo yum install -y php-mysqlnd",
      "sudo systemctl start mysqld",
      "sudo systemctl enable mysqld",

    ]
  }
}

resource "aws_instance" "webapp-server02" {
    ami = var.ami
    instance_type= var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.ssh-http-access.id]
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
      "sudo git clone https://github.com/mauricioamendola/simple-ecomme.git /var/www/html",
      "sudo systemctl restart httpd",
      "sudo yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm",
      "sudo yum install -y mysql-community-server",
      "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
      "sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm",
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --enable remi-php56",
      "sudo yum install -y php php-mcrypt php-cli php-gd",
      "sudo yum install -y php-mysqlnd",
      "sudo systemctl start mysqld",
      "sudo systemctl enable mysqld",

    ]
  }
}

resource "aws_vpc" "vpc-practico-3tier" { 
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-practico-3tier"
  }
}

resource "aws_subnet" "Internal-subnet1" {
  vpc_id                  = aws_vpc.vpc-practico-3tier.id #Asociamos un recurso creado con terraform
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.AZ1
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Internal-subnet1"
  }
}

resource "aws_subnet" "Internal-subnet2" {
  vpc_id                  = aws_vpc.test-terraform-vpc.id #Asociamos un recurso creado con terraform
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.AZ2
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Internal-subnet2"
  }
}

resource "aws_lb" "ALB-Ecommerce" {
  name               = "alb-ecommerce"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false
}



resource "aws_route_table" "test-terraform-rt" {
  vpc_id                  = aws_vpc.vpc-practico-3tier.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-terraform-ig.id
  }

}