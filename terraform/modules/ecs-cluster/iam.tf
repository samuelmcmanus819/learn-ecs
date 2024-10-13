data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_execution_role" {
  for_each = {
    "web"    = "jenkins-web-execution-role"
    "runner" = "jenkins-runner-execution-role"
  }


  name = each.value
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
  for_each = {
    "web"    = "jenkins-web-task-role"
    "runner" = "jenkins-runner-task-role"
  }

  name = each.value
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

resource "aws_iam_policy" "ecs_task_exec_policy" {
  name        = "ecs-exec-policy"
  path        = "/"
  description = "Policy for ECS Exec"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ecs:ExecuteCommand"]
        Resource = [
          module.jenkins_web_server.task_arn,
          module.jenkins_runner.task_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_web_execution_secrets_policy" {
  name        = "ecs-web-task-secrets-policy"
  path        = "/"
  description = "Policy for ECS Task to read Jenkins secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          var.jenkins_admin_password_secret_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_web_task_secrets_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role["web"].name
  policy_arn = aws_iam_policy.ecs_web_execution_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_exec_task_role_policy_attachment" {
  for_each   = aws_iam_role.ecs_task_role
  role       = aws_iam_role.ecs_task_role[each.key].name
  policy_arn = aws_iam_policy.ecs_task_exec_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_efs_task_role_policy_attachment" {
  for_each   = aws_iam_role.ecs_task_role
  role       = aws_iam_role.ecs_task_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  for_each   = aws_iam_role.ecs_execution_role
  role       = aws_iam_role.ecs_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  for_each   = aws_iam_role.ecs_task_role
  role       = aws_iam_role.ecs_task_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

