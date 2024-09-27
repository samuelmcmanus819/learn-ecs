module "ecs_cluster" {
  source    = "./modules/ecs-cluster"
  subnet_id = var.subnet_id
}