# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-asg"
  min_size            = 1
  max_size            = 6
  desired_capacity    = 1

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  health_check_type          = "ELB"
  health_check_grace_period  = 120

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.web_tg.arn
  ]

  tag {
    key                 = "Name"
    value               = "web-server-asg"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"

  lifecycle {
    create_before_destroy = true
  }
}

# 🔹 Scale Up Policy
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 0

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# 🔹 Scale Down Policy
resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "cpu-scale-down"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 60 # optional small delay for scaling down

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0 # Scale down if average CPU drops below 30%
  }
}
