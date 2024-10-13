output "jenkins_web_public_ip" {
  value = module.ecs_cluster.jenkins_web_public_ip
} 

output "agent_secret" {
  value = module.ecs_cluster.agent_secret
}