provider "aws" {
    region = "us-east-1"
}

  module "deploy-instance" {
  source = "./modules/custom-deploy"
  aws_region  = "us-east-1"
  vpc_cidr = "172.16.0.0/16"
  AZ = "us-east-1a"
  ami = "ami-098e39bafa7e7303d"
  key = "vockey"
  instance_type = "t3.micro"
  }

terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-frodriguez"
    dynamodb_table = "terraform-lock-table"
    key    = "Implementacion_de_Soluciones_Cloud26/terraform.tfstate"
    region = "us-east-1"
  }
}

output "ec2-instance-id" {
  value = module.deploy-instance.ec2-instance-id
}

output "ec2-instance-dns" {
  value = module.deploy-instance.ec2-instance-dns
}

output "ec2-instance-tags" {
  value = module.deploy-instance.ec2-instance-tags
}

output "vpc-id" {
  value = module.deploy-instance.vpc-id
}