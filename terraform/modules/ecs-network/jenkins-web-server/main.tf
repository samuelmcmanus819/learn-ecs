resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Rules for the web server security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "web_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id            = aws_security_group.web_server_sg.id
  referenced_security_group_id = var.alb_security_group
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_runner_http" {
  security_group_id            = aws_security_group.web_server_sg.id
  referenced_security_group_id = var.runner_sg
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_efs_from_ecs" {
  description                  = "Allow JNLP from Runner"
  security_group_id            = aws_security_group.web_server_sg.id
  referenced_security_group_id = var.runner_sg
  from_port                    = 50000
  to_port                      = 50000
  ip_protocol                  = "tcp"
}

# Web server is intended to be used universally
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "allow_web_server_all_outbound" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}