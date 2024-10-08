resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  description = "Allow NFS access to EFS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "efs-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_efs_from_ecs" {
  description                  = "Allow NFS from ECS tasks"
  security_group_id            = aws_security_group.efs_sg.id
  referenced_security_group_id = var.web_server_security_group_id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_efs_to_ecs" {
  security_group_id            = aws_security_group.efs_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.web_server_security_group_id
  from_port                    = 0
  to_port                      = 0
}


