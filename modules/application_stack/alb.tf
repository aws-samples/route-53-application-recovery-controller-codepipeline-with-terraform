
# ---------------------------------------------------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb" "alb" {
  name            = "${var.stack}-alb"
  internal           = false
  load_balancer_type = "application"
  
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb-sg.id]
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB TARGET GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "trgp" {
  name        = "${var.stack}-tgrp"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  deregistration_delay = 30
  
  health_check {
    enabled  = "true"
    healthy_threshold = 3
    interval = 5
    timeout  = 3
  }   

  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 3600    
    enabled         = "true"  
  }   

}

# ---------------------------------------------------------------------------------------------------------------------
# ALB LISTENER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.trgp.id
    type             = "forward"
  }
}

output "alb_address" {
  value = aws_alb.alb.dns_name
}