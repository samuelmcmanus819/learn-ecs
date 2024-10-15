# Jenkins Web Server on ECS

This project sets up a Jenkins web server running on Amazon ECS (Elastic Container Service) using Fargate. It's designed to provide a scalable and manageable Jenkins environment in the AWS cloud.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Resources Created](#resources-created)

## Purpose
The purpose of this project is for me to get more familiar with Terraform, ECS, and related AWS security services. This isn't intended to be used as a module, primarily because many of the resources (like SCPs and the WAF) would typically be managed in external modules/repos.

## Features

- ECS Fargate cluster with a Jenkins service
    - Jenkins web server behind an ALB to enable security add-ons
    - Configurable number of runners
- Persistent storage using Amazon EFS
- WAF attached to ALB, utilizing default AWS ruleset to protect against common attacks
- SCPs implemented to prevent some insecure configurations
- Strict networking rules to ensure minimal threat surface
- Logging bucket attached to 
- Support for executing commands in the container
- Devcontainer for centrally-managed development environment
- GitHub workflow for automated deployments
- AWS flow logs enabled in VPC

## Future Work
- Implement a basic WAF and connect to the ALB

## Recommended Improvements
- There is no TLS used on the Jenkins server, because I didn't want to buy a domain name
  - Option 1: Implement partial TLS termination - buy a domain, plug it into the ALB, and create a certificate for it, then enable a 443 listener on the LB forwarded to 8080 on Jenkins
  - Option 2: Implement full TLS termination - buy a domain, plug it into the ALB, and create a certificate for it, install the cert on the Jenkins server and have the ALB forward from 443 to 443
- Implement access logging on ALB
- Enable Cloudwatch logging for ECS tasks (code is already there, but I didn't want to spend the money keeping it on)

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

## Resources Created
- Logging Bucket
- ECS Cluster
- ECS Service/Task for Jenkins web server
- TBD: ECS Service/Task for Jenkins runner
- EFS Volume for ECS tasks