# Jenkins Web Server on ECS

This project sets up a Jenkins web server running on Amazon ECS (Elastic Container Service) using Fargate. It's designed to provide a scalable and manageable Jenkins environment in the AWS cloud.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)
- [Resources Created](#resources-created)


## Features

- ECS Fargate cluster with a Jenkins service
    - Jenkins web server 
    - Configurable number of runners
- Persistent storage using Amazon EFS
- Reasonably secure networking configuration
- Support for executing commands in the container
- Devcontainer for centrally-managed development environment
- GitHub workflow for automated deployments

## Prerequisites

**Local with Devcontainer**
- Docker installed
- AWS credentials file stored at `~/.aws/credentials`
- Existing ECR repository with Jenkins web server image 

**Remote in a GitHub Action**
- A GitHub token, stored in your repository at `${{ secrets.GITHUB_TOKEN }}`
- An AWS Access Key ID, stored in your repository at `${{ secrets.AWS_ACCESS_KEY_ID }}`
- An AWS Secret Access Key, stored in your repository at `${{ secrets.AWS_SECRET_ACCESS_KEY }}`


## Usage

To use this repository, simply:
1. Build the devcontainer in VSCode
2. Move to the terraform directory `cd terraform`
3. Initialize Terraform `terraform init`
4. Deploy the ECS cluster `terraform apply -var "jenkins_web_ecr_image=<your-ecr-image>"`

Alternatively, to use this as a module, you can include the following:

```hcl
module "jenkins_web_server" {
  source = "./modules/ecs-cluster/jenkins-web-server"

  jenkins_web_ecr_image        = "<your-ecr-image>"
}
```