resource "aws_autoscaling_group" "worker_asg" {
  desired_capacity    = 0
  max_size            = 10
  min_size            = 0
  vpc_zone_identifier = module.polybot_service_vpc.public_subnets

  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "haitham-kube-worker"
    propagate_at_launch = true
    
    
  }
}
