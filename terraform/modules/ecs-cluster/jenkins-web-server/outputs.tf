output "task_arn" {
  value = aws_ecs_task_definition.jenkins_web_task.arn
}

output "jenkins_web_dns" {
  value = module.load_balancer.jenkins_web_dns
}

resource "null_resource" "wait_for_task_and_fetch_eni" {
  depends_on = [ aws_ecs_service.jenkins_web_service ]
  provisioner "local-exec" {
    command = "aws ecs wait services-stable --cluster ${var.jenkins_cluster_id} --services ${aws_ecs_service.jenkins_web_service.name} --region ${var.region}"
  }
}

data "aws_network_interface" "interface_tags" {
  depends_on = [ null_resource.wait_for_task_and_fetch_eni]
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [aws_ecs_service.jenkins_web_service.name]
  }
}

output "jenkins_web_private_ip" {
  value = data.aws_network_interface.interface_tags.private_ip
}

output "jenkins_agent_secret" {
  value = data.local_file.jenkins_output.content
}