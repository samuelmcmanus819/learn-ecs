# Get the AWS Organization details
data "aws_organizations_organization" "my_org" {}

# Get the current AWS account
data "aws_caller_identity" "current" {}

# Restrict ECS to only use the ECR repo
data "template_file" "restrict_cluster_deletion_policy" {
  template = file("${path.module}/../../../scps/restrict-cluster-deletion.json")

  vars = {
    aws_admin_arn = var.aws_admin_arn
  }
}
resource "aws_organizations_policy" "restrict_cluster_deletion_scp" {
  name        = "RestrictClusterDeletion"
  description = "Restrict cluster deletion for anyone other than the admin"
  content     = data.template_file.restrict_cluster_deletion_policy.rendered
  type        = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "restrict_cluster_deletion_scp_attachment" {
  policy_id = aws_organizations_policy.restrict_cluster_deletion_scp.id
  target_id = data.aws_organizations_organization.my_org.roots[0].id
}

# Restrict ECS to only use the ECR repo
data "template_file" "restrict_image_source" {
  template = file("${path.module}/../../../scps/restrict-images-outside-of-ecr.json")

  vars = {
    account_id = data.aws_caller_identity.current.account_id
  }
}
resource "aws_organizations_policy" "restrict_image_source_scp" {
  name        = "RestrictDockerRepo"
  description = "Restrict ECS from pulling from any repository other than our ECR"
  content     = data.template_file.restrict_image_source.rendered
  type        = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "restrict_image_source_scp_attachment" {
  policy_id = aws_organizations_policy.restrict_image_source_scp.id
  target_id = data.aws_caller_identity.current.id
}

# Restrict public IP addresses on ECS resources
resource "aws_organizations_policy" "restrict_public_ecs_services" {
  name        = "RestrictPublicECS"
  description = "Prevents ECS services from being created with a public IP"
  content     = file("${path.module}/../../../scps/restrict-public-ecs-services.json")
  type        = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "restrict_public_ecs_services_attachment" {
  policy_id = aws_organizations_policy.restrict_public_ecs_services.id
  target_id = data.aws_organizations_organization.my_org.roots[0].id
}