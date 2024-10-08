output "web_service_subnet_ids" {
  value = [aws_subnet.ecs_vpc_public_subnet.id]
}

output "web_server_security_groups" {
  value = [aws_security_group.web_server_sg.id]
}

output "efs_security_group" {
  value = aws_security_group.efs_sg.id
}

output "jenkins_vpc_id" {
  value = aws_vpc.ecs_vpc.id
}