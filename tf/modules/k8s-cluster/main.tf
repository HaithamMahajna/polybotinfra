

module "polybot_service_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "kube_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
}


resource "aws_instance" "node" {
  ami                         = var.ami_id #  control plane's AMI
  instance_type               = "t2.medium"
  subnet_id                   = module.polybot_service_vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.control_plane_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/init.sh")
  key_name                    = var.key_name
  iam_instance_profile = aws_iam_instance_profile.haitham_ec2_profile.name


  root_block_device {
    volume_size = 25
    volume_type = "gp3"
    delete_on_termination = true
  }



  tags = {
    Name = "haitham-control-plane"
  }
}


resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Allow Kubernetes control plane traffic"
  vpc_id      = module.polybot_service_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
  }

  ingress {
    from_port   = 6443 # kube-apiserver
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Or limit to trusted IPs/nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # all protocols
    cidr_blocks = ["10.0.0.0/16"] # all IPs within the VPC
  }

}








