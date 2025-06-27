resource "aws_launch_template" "worker_lt" {
  name_prefix   = "haitham-kube-worker-"
  image_id      = var.ami_id
  instance_type = "t2.medium"
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.haitham_ec2_profile.name
}

  user_data = filebase64("${path.module}/init-worker.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.worker_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "haitham-kube-worker"
    }
  }


}



resource "aws_security_group" "worker_sg" {
  name   = "kube-worker-sg"
  vpc_id = module.polybot_service_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # allow traffic within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
