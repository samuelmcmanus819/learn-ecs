resource "aws_lb" "jenkins_web_alb" {
    name = "jenkins-web-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_security_group]
    subnets = var.alb_subnet_ids 
}

resource "aws_lb_target_group" "jenkins_web_target_group" {
  name     = "jenkins-web-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.jenkins_web_alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward" 
      target_group_arn = aws_lb_target_group.jenkins_web_target_group.arn
    }
}