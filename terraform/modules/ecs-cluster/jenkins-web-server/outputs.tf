output "task_arn" {
  value = aws_ecs_task_definition.jenkins_web_task.arn
}

output "jenkins_web_public_ip" {
    value = data.aws_network_interface.interface_tags.association[0].public_ip
}

output "jenkins_web_private_ip" {
  value = data.aws_network_interface.interface_tags.private_ip
}

output "jenkins_agent_secret" {
  value = data.local_file.jenkins_output.content
}