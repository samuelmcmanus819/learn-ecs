resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
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

resource "aws_subnet" "ecs_vpc_public_subnet" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "ecs_internet_gateway" {
  vpc_id = aws_vpc.ecs_vpc.id
}

resource "aws_nat_gateway" "ecs_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.ecs_vpc_public_subnet.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_internet_gateway.id
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.ecs_vpc_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "ecs_vpc_private_subnet" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecs_nat_gateway.id
  }
}

resource "aws_route_table_association" "private_route_table_assoc" {
  subnet_id      = aws_subnet.ecs_vpc_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

module "jenkins_web_server_network" {
  source = "./jenkins-web-server"
  vpc_id = aws_vpc.ecs_vpc.id
}

module "efs_network" {
  source = "./efs"
  vpc_id = aws_vpc.ecs_vpc.id
  web_server_security_group_id = module.jenkins_web_server_network.security_group_id
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
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [aws_subnet.ecs_vpc_public_subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}

# VPC Endpoint for SSM Messages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.ecs_vpc.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [aws_subnet.ecs_vpc_public_subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}

# VPC Endpoint for ECS
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.ecs_vpc.id
  service_name        = "com.amazonaws.us-east-1.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [aws_subnet.ecs_vpc_public_subnet.id] # only include one per AZ
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
}
