output "vpc_id" {
  value = module.k8s-cluster.vpc_id
}

output "public_subnets" {
  value = module.k8s-cluster.public_subnets
}
output "instance_public_ip" {
  description = "Public IP of the control plane EC2 instance"
  value       = module.k8s-cluster.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP of the control plane EC2 instance"
  value       = module.k8s-cluster.instance_private_ip
}