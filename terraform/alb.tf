# ALB
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.elb_sg.id]
  subnets           = [
    aws_subnet.sub1.id,
    aws_subnet.sub2.id
  ]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.elb.id
  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# ALB Listener
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Hello from ALB"
    }
  }
}

# Regist EC2 Instance to ALB Target Group
resource "aws_lb_target_group_attachment" "my_attachment_server1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_attachment_server2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.server2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_attachment_server3" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.server3.id
  port             = 80
}
