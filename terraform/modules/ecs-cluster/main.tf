resource "aws_ecs_cluster" "my_cluster" {
  name = "learn-ecs-cluster"

  # Disable container insights because it's expensive
  setting {
    name = "containerInsights"
    # tfsec:ignore:aws-ecs-enable-container-insight
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "learn-ecs-task-definition"
  network_mode             = "awsvpc" # Required for Fargate
  cpu                      = "256"    # .25 vCPU
  memory                   = "512"    # .5 MiB
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name      = "learnecsapp"
    image     = "nginx:alpine"
    essential = true
    portMappings = [{
      name          = "http"
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
      appProtocol   = "http"
    }]
  }])
} 

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE" # Specifies Fargate

  network_configuration {
    subnets          = var.web_server_subnet_ids
    security_groups  = var.web_server_security_groups
    assign_public_ip = true
  }
}
