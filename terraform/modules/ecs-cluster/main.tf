resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "learn-ecs-cluster"

  # Disable container insights because it's expensive
  setting {
    name = "containerInsights"
    # tfsec:ignore:aws-ecs-enable-container-insight
    value = "disabled"
  }
}

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

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "jenkins_web_task" {
  family                   = "learn-ecs-task-definition"
  network_mode             = "awsvpc" # Required for Fargate
  cpu                      = "256"    # .25 vCPU
  memory                   = "512"    # .5 MiB
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "jenkins_web"
    image     = "${var.jenkins_ecr_image}"
    essential = true
    portMappings = [{
      name          = "http"
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
      appProtocol   = "http"
    }]
  }])
}

resource "aws_ecs_service" "jenkins_web_service" {
  name            = "jenkins_web_service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_web_task.arn
  desired_count   = 1
  launch_type     = "FARGATE" # Specifies Fargate

  network_configuration {
    subnets          = var.jenkins_web_subnet_ids
    security_groups  = var.jenkins_web_security_groups
    assign_public_ip = true
  }
}
