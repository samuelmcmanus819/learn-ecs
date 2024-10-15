output "target_group_arn" {
  value = aws_lb_target_group.jenkins_web_target_group.arn
}

output "jenkins_web_dns" {
  value = aws_lb.jenkins_web_alb.dns_name
}