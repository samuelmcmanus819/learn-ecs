module "logging_bucket" {
  source              = "./modules/logging-bucket"
  logging_bucket_name = "learn-ecs-logging-bucket"
}

module "scps" {
  source        = "./modules/scps"
  aws_admin_arn = var.aws_admin_arn
}

module "ecs_network" {
  source         = "./modules/ecs-network"
  region         = var.region
  subnets        = var.subnets
  log_bucket_arn = module.logging_bucket.bucket_arn
}

module "ecs_cluster" {
  depends_on                        = [module.scps]
  source                            = "./modules/ecs-cluster"
  region                            = var.region
  alb_subnet_ids                    = module.ecs_network.public_subnet_ids
  jenkins_web_subnet_ids            = module.ecs_network.private_subnet_ids
  jenkins_runner_subnet_ids         = module.ecs_network.private_subnet_ids
  alb_security_group                = module.ecs_network.alb_security_group
  jenkins_web_security_group        = module.ecs_network.web_server_security_group
  jenkins_runner_security_group     = module.ecs_network.runner_security_group
  jenkins_efs_security_group        = module.ecs_network.efs_security_group
  ecr_registry                      = var.ecr_registry
  jenkins_runner_ecr_image          = var.jenkins_runner_ecr_image
  jenkins_web_ecr_image             = var.jenkins_web_ecr_image
  jenkins_vpc_id                    = module.ecs_network.jenkins_vpc_id
  jenkins_runner_deploy_count       = var.jenkins_runner_deploy_count
  jenkins_admin_username            = var.jenkins_admin_username
  jenkins_admin_password            = var.jenkins_admin_password
  jenkins_admin_password_secret_id  = var.jenkins_admin_password_secret_id
  jenkins_admin_password_secret_arn = var.jenkins_admin_password_arn
}