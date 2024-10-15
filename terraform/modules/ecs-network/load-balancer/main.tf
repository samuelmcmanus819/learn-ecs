resource "aws_security_group" "alb_security_group" {
  name        = "alb_security_group"
  description = "Rules for the ALB security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_sg"
  }
}

# ALB is intended to be used universally
#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Web server is intended to be used universally
#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "allow_alb_http_ipv6" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Web server is intended to be used universally
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "allow_alb_all_outbound" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}