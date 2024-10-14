output "jenkins_web_dns" {
  value = module.ecs_cluster.jenkins_web_dns
}

output "agent_secret" {
  value = module.ecs_cluster.agent_secret
}