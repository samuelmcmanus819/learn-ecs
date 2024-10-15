variable "region" {
  type = string
}

variable "subnets" {
  type = list(object({
    name               = string
    public_cidr_block  = string
    private_cidr_block = string
    az                 = string
  }))
}

variable "log_bucket_arn" {
  type = string
}