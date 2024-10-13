output "jenkins_web_public_ip" {
  value = module.jenkins_web_server.jenkins_web_public_ip
}

output "agent_secret" {
  value = module.jenkins_web_server.jenkins_agent_secret
}