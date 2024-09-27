data "aws_subnet" "ecs_subnet" {
  id = var.subnet_id
}

data "aws_vpc" "ecs_vpc" {
  id = data.aws_subnet.ecs_subnet.vpc_id
}

resource "aws_security_group" "ecs_security_group" {
  name        = "allow_http"
  description = "Allow HTTP inbound and all outbound traffic"
  vpc_id      = data.aws_vpc.ecs_vpc.id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

}

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
    subnets          = [data.aws_subnet.ecs_subnet.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}
