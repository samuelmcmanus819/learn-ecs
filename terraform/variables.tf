variable "region" {
  type    = string
  default = "us-east-1"
}

variable "subnets" {
  type = list(object({
    name               = string
    public_cidr_block  = string
    private_cidr_block = string
    az                 = string
  }))

  default = [{
    az                 = "us-east-1a"
    public_cidr_block  = "10.0.1.0/24"
    private_cidr_block = "10.0.3.0/24"
    name               = "subnet_a"
    }, {
    az                 = "us-east-1b"
    public_cidr_block  = "10.0.2.0/24"
    private_cidr_block = "10.0.4.0/24"
    name               = "subnet_b"
  }]
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


variable "jenkins_admin_password_secret_id" {
  type    = string
  default = "jenkins-admin-password"
}

variable "jenkins_admin_password_arn" {
  type = string
}

variable "aws_admin_arn" {
  type = string
}