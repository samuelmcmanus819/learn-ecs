module "logging_bucket" {
  source              = "./modules/logging-bucket"
  logging_bucket_name = "learn-ecs-logging-bucket"
}

module "ecs_network" {
  source            = "./modules/ecs-network"
  region            = var.region
  availability_zone = var.availability_zone
  log_bucket_arn    = module.logging_bucket.bucket_arn
}

module "ecs_cluster" {
  source                            = "./modules/ecs-cluster"
  region                            = var.region
  jenkins_web_subnet_id             = module.ecs_network.web_server_subnet_id
  jenkins_runner_subnet_id          = module.ecs_network.runner_subnet_id
  jenkins_web_security_group        = module.ecs_network.web_server_security_group
  jenkins_runner_security_group     = module.ecs_network.runner_security_group
  jenkins_efs_security_group        = module.ecs_network.efs_security_group
  jenkins_web_ecr_image             = var.jenkins_web_ecr_image
  jenkins_vpc_id                    = module.ecs_network.jenkins_vpc_id
  jenkins_runner_deploy_count       = var.jenkins_runner_deploy_count
  jenkins_admin_username            = var.jenkins_admin_username
  jenkins_admin_password            = var.jenkins_admin_password
  jenkins_admin_password_secret_id  = var.jenkins_admin_password_secret_id
  jenkins_agent_secret_id           = var.jenkins_agent_secret_id
  jenkins_agent_secret              = var.jenkins_agent_secret
  jenkins_admin_password_secret_arn = var.jenkins_admin_password_arn
  jenkins_agent_secret_arn          = var.jenkins_agent_secret_arn
}

output "jenkins_web_public_ip" {
  value = module.ecs_cluster.jenkins_web_public_ip
} 