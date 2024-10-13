variable "region" {
  type = string
}
variable "jenkins_web_subnet_id" {
  type = string
}

variable "jenkins_runner_subnet_id" {
  type = string
}

variable "jenkins_web_security_group" {
  type = string
}

variable "jenkins_runner_security_group" {
  type = string
}

variable "jenkins_efs_security_group" {
  type = string
}

variable "jenkins_web_ecr_image" {
  type = string
}

variable "jenkins_vpc_id" {
  type = string
}

variable "jenkins_runner_deploy_count" {
  type = number
}


variable "jenkins_admin_username" {
  type = string
}

variable "jenkins_admin_password" {
  type = string
}

variable "jenkins_admin_password_secret_id" {
  type = string
}

variable "jenkins_admin_password_secret_arn" {
  type = string
}

