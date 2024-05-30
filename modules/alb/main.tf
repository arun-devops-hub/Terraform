
resource "aws_instance" "instance_a" { 
 count = length(local.public_subnet_ids)
 ami           = data.aws_ami.ubuntu.id
 instance_type = var.instance_type

 subnet_id = local.public_subnet_ids[count.index]
 vpc_security_group_ids = [aws_security_group.alb_sg.id]

 key_name = "tf_key"

 tags = {
   Name = "web-server-${count.index}"
 }
}
 

resource "aws_key_pair" "my_tf_key" {
    key_name = "tf_key"
    public_key = var.public_key
}

resource "aws_lb_target_group" "alb_tg" {
  count    = 3  # Number of target groups
  name     = "web-tg-${count.index}"
  port     = var.port  # Specify your port
  protocol = var.protocol  # Specify your protocol
  vpc_id   = data.aws_vpc.togetvpc_id.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-tg-${count.index}"
  }
}

#Attach instance to target group
#Uses the count parameter to iterate over the instances and target groups.
#count.index % length(aws_lb_target_group.example) ensures that each instance is attached to each target group in a round-robin manner.
#count.index / length(aws_lb_target_group.example) calculates the appropriate instance ID to attach.

resource "aws_lb_target_group_attachment" "example" {
  for_each        = { for i, instance in aws_instance.instance_a : "${i}-${instance.id}" => instance }
  target_group_arn = aws_lb_target_group.alb_tg[tonumber(split("-", each.key)[0])].arn
  target_id        = each.value.id
  port             = 80  # Port on which the instance is listening
}

resource "aws_lb" "my_alb" {
 name               = "my-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.mainalb_sg.id]
 subnets            = ["subnet-040a19bdd05a7d574", "subnet-05e4bb68f78b75902","subnet-0fa69d28835993aa1"]
 tags = {
   Environment = "dev"
 }
}

resource "aws_security_group" "mainalb_sg" {
     name = "allow_alb"

  vpc_id = data.aws_vpc.togetvpc_id.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg[0].arn
  }
}

resource "aws_lb_listener_rule" "rule1" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg[1].arn
  }

  condition {
    path_pattern {
      values = ["/pithapuram/*"]
    }
  }
}

resource "aws_lb_listener_rule" "rule2" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg[2].arn
  }

  condition {
    path_pattern {
      values = ["/kuppam/*"]
    }
  }
}


