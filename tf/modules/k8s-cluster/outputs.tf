output "vpc_id" {
  value = module.polybot_service_vpc.vpc_id
}

output "public_subnets" {
  value = module.polybot_service_vpc.public_subnets
}
output "instance_public_ip" {
  description = "Public IP of the control plane EC2 instance"
  value       = aws_instance.node.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the control plane EC2 instance"
  value       = aws_instance.node.private_ip
}