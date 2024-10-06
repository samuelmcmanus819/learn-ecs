resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
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

resource "aws_subnet" "ecs_vpc_private_subnet" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.2.0/24"
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

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Rules for the web server security group"
  vpc_id      = aws_vpc.ecs_vpc.id

  tags = {
    Name = "web_server_sg"
  }
}

#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv6         = "::/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

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

output "web_service_subnet_ids" {
  value = [aws_subnet.ecs_vpc_public_subnet.id]
}

output "web_server_security_groups" {
  value = [aws_security_group.web_server_sg.id]
}