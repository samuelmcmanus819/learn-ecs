output "web_service_subnet_id" {
  value = aws_subnet.ecs_vpc_public_subnet.id
}

output "web_server_security_group" {
  value = module.jenkins_web_server_network.security_group_id
}

output "efs_security_group" {
  value = module.efs_network.security_group_id
}

output "jenkins_vpc_id" {
  value = aws_vpc.ecs_vpc.id
}