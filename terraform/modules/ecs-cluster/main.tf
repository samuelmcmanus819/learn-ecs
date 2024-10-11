resource "aws_secretsmanager_secret_version" "jenkins_agent_secret_value" {
  secret_id     = var.jenkins_agent_secret_id
  secret_string = var.jenkins_agent_secret
}

resource "aws_secretsmanager_secret_version" "jenkins_admin_password_secret_value" {
  secret_id     = var.jenkins_admin_password_secret_id
  secret_string = var.jenkins_admin_password
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-cluster"

  # Disable container insights because it's expensive
  setting {
    name = "containerInsights"
    # tfsec:ignore:aws-ecs-enable-container-insight
    value = "disabled"
  }
}

module "jenkins_web_server" {
  source                       = "./jenkins-web-server"
  region                       = var.region
  jenkins_web_ecr_image        = var.jenkins_web_ecr_image
  jenkins_web_subnet_id        = var.jenkins_web_subnet_id
  jenkins_web_security_group   = var.jenkins_web_security_group
  jenkins_volume_id            = aws_efs_file_system.jenkins_volume.id
  jenkins_home_access_point_id = aws_efs_access_point.jenkins_home.id
  jenkins_cert_access_point_id = aws_efs_access_point.jenkins_certs.id
  jenkins_cluster_id           = aws_ecs_cluster.jenkins_cluster.id
  jenkins_agent_secret_arn     = var.jenkins_agent_secret_arn
  jenkins_admin_username       = var.jenkins_admin_username
  jenkins_admin_password_arn   = var.jenkins_admin_password_secret_arn
  execution_role_arn           = aws_iam_role.ecs_task_role["web"].arn
  task_role_arn                = aws_iam_role.ecs_task_role["web"].arn
}

module "jenkins_runner" {
  source                        = "./jenkins-runner"
  jenkins_runner_subnet_id      = var.jenkins_runner_subnet_id
  jenkins_runner_security_group = var.jenkins_runner_security_group
  jenkins_volume_id             = aws_efs_file_system.jenkins_volume.id
  jenkins_home_access_point_id  = aws_efs_access_point.jenkins_home.id
  jenkins_cert_access_point_id  = aws_efs_access_point.jenkins_certs.id
  jenkins_cluster_id            = aws_ecs_cluster.jenkins_cluster.id
  jenkins_agent_secret          = var.jenkins_agent_secret_arn
  jenkins_master_ip             = module.jenkins_web_server.jenkins_web_public_ip
  execution_role_arn            = aws_iam_role.ecs_execution_role["runner"].arn
  task_role_arn                 = aws_iam_role.ecs_execution_role["runner"].arn
  deploy_count                  = var.jenkins_runner_deploy_count
}

