output "jenkins_web_dns" {
  value = module.jenkins_web_server.jenkins_web_dns
}

output "agent_secret" {
  value = module.jenkins_web_server.jenkins_agent_secret
}