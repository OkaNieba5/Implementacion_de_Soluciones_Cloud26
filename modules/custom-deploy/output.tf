output "ec2-instance-id" {
  value = aws_instance.ec2-instance-ecommerce.id
}

output "ec2-instance-dns" {
  value = aws_instance.ec2-instance-ecommerce.public_dns
}

output "ec2-instance-tags" {
  value = aws_instance.ec2-instance-ecommerce.tags
}

output "vpc-id" {
  value = aws_vpc.test-terraform-vpc.id
}