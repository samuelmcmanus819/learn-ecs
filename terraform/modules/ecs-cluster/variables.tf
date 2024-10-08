variable "jenkins_web_subnet_id" {
  type = string
}


variable "jenkins_web_security_group" {
  type = string
}

variable "jenkins_efs_security_group" {
  type = string
}

variable "jenkins_web_ecr_image" {
  type    = string
  default = "286812073492.dkr.ecr.us-east-1.amazonaws.com/learn-ecs:latest"
}

variable "jenkins_vpc_id" {
  type = string
}