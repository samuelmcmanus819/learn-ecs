variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "jenkins_web_ecr_image" {
  type    = string
}

variable "jenkins_runner_deploy_count" {
  type    = number
  default = 1
}

variable "jenkins_admin_username" {
  type    = string
  default = "Sam"
}

variable "jenkins_admin_password" {
  type = string
}

variable "jenkins_agent_secret" {
  type = string
}

variable "jenkins_admin_password_secret_id" {
  type    = string
  default = "jenkins-admin-password"
}

variable "jenkins_agent_secret_id" {
  type    = string
  default = "jenkins-agent-secret"
}

variable "jenkins_admin_password_arn" {
  type    = string
}

variable "jenkins_agent_secret_arn" {
  type    = string
}