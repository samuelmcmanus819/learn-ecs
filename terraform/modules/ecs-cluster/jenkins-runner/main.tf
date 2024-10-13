data "aws_region" "current" { }
resource "aws_cloudwatch_log_group" "jenkins_runner_logs" {
  name              = "/ecs/jenkins-agent"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "jenkins_runner" {
  family                   = "jenkins-agent"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "jenkins-agent"
      image = "jenkins/inbound-agent:latest"
      essential = true
      
      environment = [
        {
          name  = "JENKINS_URL"
          value = "http://${var.jenkins_master_ip}:8080"
        },
        {
          name  = "JENKINS_AGENT_NAME"
          value = "agent1"
        },
        {
          name  = "JENKINS_SECRET"
          value = var.jenkins_agent_secret
        }
      ]
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/jenkins-agent"
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
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

resource "aws_ecs_service" "jenkins_runner_service" {
  name            = "jenkins-runner-service"
  cluster         = var.jenkins_cluster_id
  task_definition = aws_ecs_task_definition.jenkins_runner.arn
  desired_count   = var.deploy_count
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
  launch_type     = "FARGATE" # Specifies Fargate
  enable_execute_command = true
  enable_ecs_managed_tags = true

  network_configuration {
    subnets          = [var.jenkins_runner_subnet_id]
    security_groups  = [var.jenkins_runner_security_group]
  }
}