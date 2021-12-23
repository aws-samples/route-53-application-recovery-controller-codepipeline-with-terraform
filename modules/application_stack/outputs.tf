output "alb" {
  value = aws_alb.alb
}

output "asg" {
  value = aws_autoscaling_group.app_asg
}

