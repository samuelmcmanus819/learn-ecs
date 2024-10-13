resource "aws_security_group" "runner_sg" {
  name        = "runner_sg"
  description = "Rules for the runner security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "runner_sg"
  }
}

# Allow runner to access outbound for downloads
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "allow_runner_all_outbound" {
  security_group_id = aws_security_group.runner_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "-1" # semantically equivalent to all ports
}