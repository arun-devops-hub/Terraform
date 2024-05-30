// modules/auto_scaling_group/main.tf

resource "aws_launch_configuration" "lc" {
  name          = "${var.name}-launch-configuration"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = ["aws_security_group.asg_sg.id"]

   user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              echo "hi, from ASg ! > /var/www/html/index.html
              EOF


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_group" {
  launch_configuration = aws_launch_configuration.lc.id
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = local.public_subnet_ids
  target_group_arns    = [for tg in data.aws_lb_target_group.example : tg.arn]
  health_check_type    = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}
