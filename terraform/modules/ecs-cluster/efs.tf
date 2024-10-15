resource "aws_efs_file_system" "jenkins_volume" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  encrypted = true
}


resource "aws_efs_mount_target" "jenkins_volume_mount" {
  count           = length(var.jenkins_web_subnet_ids)
  file_system_id  = aws_efs_file_system.jenkins_volume.id
  subnet_id       = var.jenkins_web_subnet_ids[count.index]
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