variable "region" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "jenkins_web_subnet_ids" {
  type = list(string)
}

variable "jenkins_runner_subnet_ids" {
  type = list(string)
}

variable "alb_security_group" {
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

variable "ecr_registry" {
  type = string
}

variable "jenkins_runner_ecr_image" {
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

variable "web_acl_arn" {
  type = string
}