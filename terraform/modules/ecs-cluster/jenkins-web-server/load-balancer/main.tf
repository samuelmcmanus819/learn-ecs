# ALB is intended to be exposed to the internet
#trivy:ignore:AVD-AWS-0053
resource "aws_lb" "jenkins_web_alb" {
  name                       = "jenkins-web-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group]
  subnets                    = var.alb_subnet_ids
  drop_invalid_header_fields = true
}

# Step 2: Attach WAF to ALB
resource "aws_wafv2_web_acl_association" "alb_waf_association" {
  resource_arn = aws_lb.jenkins_web_alb.arn
  web_acl_arn  = var.web_acl_arn
}

resource "aws_lb_target_group" "jenkins_web_target_group" {
  name        = "jenkins-web-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# Partial TLS termination is a future improvement
#trivy:ignore:AVD-AWS-0054
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins_web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_web_target_group.arn
  }
}