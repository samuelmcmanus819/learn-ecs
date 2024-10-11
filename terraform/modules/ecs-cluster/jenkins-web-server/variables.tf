variable "region" {
  type = string
}

variable "jenkins_web_ecr_image" {
  type = string
}

variable "jenkins_web_subnet_id" {
  type = string
}

variable "jenkins_web_security_group" {
  type = string
}

variable "jenkins_volume_id" {
  type = string
}

variable "jenkins_home_access_point_id" {
  type = string
}

variable "jenkins_cert_access_point_id" {
  type = string
}

variable "jenkins_cluster_id" {
  type = string
}

variable "jenkins_admin_username" {
  type = string
}
variable "jenkins_admin_password_arn" {
  type = string
}

variable "jenkins_agent_secret_arn" {
  type = string
}

variable "execution_role_arn" {
    type = string
}

variable "task_role_arn" {
    type = string
}