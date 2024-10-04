module "logging_bucket" {
  source = "./modules/logging-bucket"
  logging_bucket_name = "learn-ecs-logging-bucket"
}

module "ecs_network" {
  source = "./modules/ecs-network"
  log_bucket_arn = module.logging_bucket.bucket_arn
}

module "ecs_cluster" {
  source                     = "./modules/ecs-cluster"
  web_server_subnet_ids      = module.ecs_network.web_service_subnet_ids
  web_server_security_groups = module.ecs_network.web_server_security_groups
}