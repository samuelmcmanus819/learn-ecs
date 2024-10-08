resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
}

data "aws_iam_policy_document" "ecs_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ecs:ExecuteCommand"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec" {
  name        = "ecs-exec-policy"
  path        = "/"
  description = "Policy for ECS Exec"
  policy      = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

# resource "aws_cloudwatch_log_group" "jenkins_web_logs" {
#   name              = "/ecs/jenkins-web-server"
#   retention_in_days = 30
# }

resource "aws_ecs_task_definition" "jenkins_web_task" {
  family                   = "learn-ecs-task-definition"
  network_mode             = "awsvpc" # Required for Fargate
  cpu                      = "1024"    # 1 vCPU
  memory                   = "2048"    # 2 MiB
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "jenkins_web"
    image     = "${var.jenkins_web_ecr_image}"
    essential = true
    portMappings = [{
      name          = "http"
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
      appProtocol   = "http"
    }]
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
    #       "awslogs-region"        = "us-east-1" 
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
  desired_count   = 1
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
  launch_type     = "FARGATE" # Specifies Fargate
  enable_execute_command = true

  network_configuration {
    subnets          = var.jenkins_web_subnet_ids
    security_groups  = var.jenkins_web_security_groups
    assign_public_ip = true
  }
}
