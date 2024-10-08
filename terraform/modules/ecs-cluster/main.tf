resource "aws_efs_file_system" "jenkins_volume" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}


resource "aws_efs_mount_target" "jenkins_web_volume_mount" {
  file_system_id  = aws_efs_file_system.jenkins_volume.id
  subnet_id       = var.jenkins_web_subnet_id
  security_groups = [var.jenkins_efs_security_group]
}

resource "aws_efs_access_point" "jenkins_home" {
  file_system_id = aws_efs_file_system.jenkins_volume.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/jenkins_home"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = 0755
    }
  }
}

resource "aws_efs_access_point" "jenkins_certs" {
  file_system_id = aws_efs_file_system.jenkins_volume.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/certs/client"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = 0755
    }
  }
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-cluster"

  # Disable container insights because it's expensive
  setting {
    name = "containerInsights"
    # tfsec:ignore:aws-ecs-enable-container-insight
    value = "disabled"
  }
}

module "jenkins_web_server" {
  source                       = "./jenkins-web-server"
  jenkins_web_ecr_image        = var.jenkins_web_ecr_image
  jenkins_web_subnet_id       = var.jenkins_web_subnet_id
  jenkins_web_security_group  = var.jenkins_web_security_group
  jenkins_volume_id            = aws_efs_file_system.jenkins_volume.id
  jenkins_home_access_point_id = aws_efs_access_point.jenkins_home.id
  jenkins_cert_access_point_id = aws_efs_access_point.jenkins_certs.id
  jenkins_cluster_id           = aws_ecs_cluster.jenkins_cluster.id
}