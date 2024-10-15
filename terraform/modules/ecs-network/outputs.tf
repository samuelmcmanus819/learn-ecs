output "public_subnet_ids" {
  value = [for subnet in aws_subnet.ecs_vpc_public_subnets : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.ecs_vpc_private_subnets : subnet.id]
}

output "alb_security_group" {
  value = module.alb_network.alb_security_group
}

output "web_server_security_group" {
  value = module.jenkins_web_server_network.security_group_id
}

output "runner_security_group" {
  value = module.jenkins_runner_network.security_group_id
}

output "efs_security_group" {
  value = module.efs_network.security_group_id
}

output "jenkins_vpc_id" {
  value = aws_vpc.ecs_vpc.id
}