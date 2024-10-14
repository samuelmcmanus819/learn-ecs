resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Enable VPC Flow Logs for the VPC
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id = aws_vpc.ecs_vpc.id

  log_destination_type = "s3" # Alternatively, you can choose 's3' for storage in S3
  log_destination      = var.log_bucket_arn
  traffic_type         = "REJECT"
}

# Create an IAM Role to allow VPC to write flow logs to S3
resource "aws_iam_role" "flow_logs_role" {
  name = "flow-logs-to-s3-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "vpc-flow-logs.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

# IAM Policy to allow writing to the S3 bucket
resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "flow-logs-s3-policy"
  role = aws_iam_role.flow_logs_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource" : [
        "${var.log_bucket_arn}",
        "${var.log_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_subnet" "ecs_vpc_public_subnets" {
  for_each          = { for subnet in var.subnets : subnet.name => subnet }
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = each.value.public_cidr_block
  availability_zone = each.value.az
  tags = {
    Name = "jenkins-public-${each.value.name}"
  }
}

resource "aws_internet_gateway" "ecs_internet_gateway" {
  vpc_id = aws_vpc.ecs_vpc.id
}

resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.ecs_vpc_public_subnets

  vpc = true

  tags = {
    Name = "${each.value.tags["Name"]}-nat-eip"
  }
}
resource "aws_nat_gateway" "ecs_nat_gateway" {
  for_each      = aws_subnet.ecs_vpc_public_subnets
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "${each.value.tags["Name"]}-nat-gateway"
  }
}



resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_internet_gateway.id
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  for_each       = aws_subnet.ecs_vpc_public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "ecs_vpc_private_subnets" {
  for_each          = { for subnet in var.subnets : subnet.name => subnet }
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = each.value.private_cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "jenkins-private-${each.value.name}"
  }
}

resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.ecs_vpc_private_subnets
  vpc_id   = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecs_nat_gateway[each.key].id
  }
}

resource "aws_route_table_association" "private_route_table_assoc" {
  for_each       = aws_subnet.ecs_vpc_private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

module "jenkins_runner_network" {
  source = "./jenkins-runner"
  vpc_id = aws_vpc.ecs_vpc.id
}

module "alb_network" {
  source = "./load-balancer"
  vpc_id = aws_vpc.ecs_vpc.id
}

module "jenkins_web_server_network" {
  source    = "./jenkins-web-server"
  vpc_id    = aws_vpc.ecs_vpc.id
  runner_sg = module.jenkins_runner_network.security_group_id
}

module "efs_network" {
  source                       = "./efs"
  vpc_id                       = aws_vpc.ecs_vpc.id
  web_server_security_group_id = module.jenkins_web_server_network.security_group_id
  runner_security_group_id     = module.jenkins_runner_network.security_group_id
}


resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ecs_vpc.cidr_block]
  }
}

# VPC Endpoint for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.ecs_vpc_public_subnets : subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}

# VPC Endpoint for SSM Messages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.ecs_vpc_public_subnets : subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}

# VPC Endpoint for ECS
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.ecs_vpc_public_subnets : subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}
