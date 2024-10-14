# data "aws_region" "current" { }
# resource "aws_cloudwatch_log_group" "jenkins_web_logs" {
#   name              = "/ecs/jenkins-web-server"
#   retention_in_days = 30
# }

module "load_balancer" {
  source = "./load-balancer"
  alb_security_group = var.alb_security_group
  alb_subnet_ids = var.alb_subnet_ids
  vpc_id = var.jenkins_vpc_id
}

resource "aws_ecs_task_definition" "jenkins_web_task" {
  family                   = "jenkins-web-task"
  network_mode             = "awsvpc" # Required for Fargate
  cpu                      = "1024"    # 1 vCPU
  memory                   = "2048"    # 2 MiB
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "jenkins_web"
    image     = "${var.ecr_registry}/${var.jenkins_web_ecr_image}"
    essential = true
    portMappings = [{
      name          = "http"
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
      appProtocol   = "http"
    }, {
      name          = "jnlp"
      containerPort = 50000
      hostPort      = 50000
      protocol      = "tcp"
    }],
    environment = [{
      name  = "JENKINS_ADMIN_ID"
      value = var.jenkins_admin_username
    },
    {
      name  = "JAVA_OPTS"
      value = "-Djenkins.install.runSetupWizard=false"
    }]
    secrets = [
      {
        name      = "JENKINS_ADMIN_PASSWORD"
        valueFrom = var.jenkins_admin_password_arn
      }
    ],
    linuxParameters = {
      initProcessEnabled = true
    }
    mountPoints = [{
      sourceVolume  = "jenkins_home"
      containerPath = "/var/jenkins_home"
      }, {
      sourceVolume  = "jenkins_certs"
      containerPath = "/certs/client"
      }],
    # logConfiguration = {
    #     logDriver = "awslogs"
    #     options = {
    #       "awslogs-group"         = "/ecs/jenkins-web-server"
    #       "awslogs-region"        = var.region 
    #       "awslogs-stream-prefix" = "ecs"
    #     }
    #   }
  }])
  volume {
    name = "jenkins_home"
    efs_volume_configuration {
      file_system_id     = var.jenkins_volume_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.jenkins_home_access_point_id
        iam             = "ENABLED"
      }
    }
  }
  volume {
    name = "jenkins_certs"
    efs_volume_configuration {
      file_system_id     = var.jenkins_volume_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.jenkins_cert_access_point_id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "jenkins_web_service" {
  name            = "jenkins_web_service"
  cluster         = var.jenkins_cluster_id
  task_definition = aws_ecs_task_definition.jenkins_web_task.arn
  health_check_grace_period_seconds = 600
  desired_count   = 1
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
  launch_type     = "FARGATE" # Specifies Fargate
  enable_execute_command = true
  enable_ecs_managed_tags = true

  load_balancer {
    target_group_arn = module.load_balancer.target_group_arn
    container_name = "jenkins_web"
    container_port = 8080
  }

  network_configuration {
    subnets          = var.jenkins_web_subnet_ids
    security_groups  = [var.jenkins_web_security_group]
  }
}

