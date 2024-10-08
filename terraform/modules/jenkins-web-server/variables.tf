variable "jenkins_web_ecr_image" {
  type = string
}

variable "jenkins_web_subnet_ids" {
  type = list(string)
}

variable "jenkins_web_security_groups" {
  type = list(string)
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