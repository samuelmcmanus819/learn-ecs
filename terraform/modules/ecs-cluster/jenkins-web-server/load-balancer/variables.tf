variable "alb_security_group" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "web_acl_arn" {
  type = string
}