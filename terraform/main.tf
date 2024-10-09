module "logging_bucket" {
  source              = "./modules/logging-bucket"
  logging_bucket_name = "learn-ecs-logging-bucket"
}

module "ecs_network" {
  source         = "./modules/ecs-network"
  log_bucket_arn = module.logging_bucket.bucket_arn
}

module "ecs_cluster" {
  source                      = "./modules/ecs-cluster"
  jenkins_web_subnet_id      = module.ecs_network.web_service_subnet_id
  jenkins_web_security_group = module.ecs_network.web_server_security_group
  jenkins_efs_security_group  = module.ecs_network.efs_security_group
  jenkins_web_ecr_image       = var.jenkins_web_ecr_image
  jenkins_vpc_id              = module.ecs_network.jenkins_vpc_id
}