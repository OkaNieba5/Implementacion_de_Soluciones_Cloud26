variable "aws_region" {
    type = string
    description = "Variable para la region de AWS" 
}

variable "vpc_cidr" {
  type = string
  description = "Variable para el CIDR block"
}

variable "AZ" {
  type = string
  description = "Availability Zone"
}

variable "ami" {
  type = string
  description = "AMI de EC2"
}

variable "instance_type" {
  type = string
  description = "Tipo de instancia EC2"
}

variable "key" {
   type = string
   description = "Llave privada"
}