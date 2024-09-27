terraform {
  backend "s3" {
    bucket         = "terraform-backend-133790"    # S3 bucket name
    key            = "learn-ecs/terraform.tfstate" # Path to store the state file within the bucket
    region         = "us-east-1"                   # AWS region where the S3 bucket is located
    encrypt        = true                          # Enable server-side encryption of the state file
    dynamodb_table = "terraform-locks"             # DynamoDB table for state locking
  }
}
