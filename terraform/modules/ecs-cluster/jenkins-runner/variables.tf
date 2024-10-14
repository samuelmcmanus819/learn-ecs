variable "jenkins_cluster_id" {
    type = string
}

variable "jenkins_runner_subnet_ids" {
    type = list(string)
}

variable "jenkins_runner_security_group" {
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

variable "jenkins_master_ip" {
    type = string
}

variable "jenkins_agent_secret" {
    type = string
}

variable "execution_role_arn" {
    type = string
}

variable "task_role_arn" {
    type = string
}

variable "deploy_count" {
    type = number
}

variable "ecr_registry" {
    type = string
}

variable "ecr_image" {
    type = string
}