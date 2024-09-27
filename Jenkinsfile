pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-access-key')
    }

    stages {
        stage('Scan Terraform') {
            agent {
                docker {
                    image 'aquasec/tfsec:v1.28'
                     args '--entrypoint="" --user="root"'
                }
            }
            steps {
                sh '''
                    cd jenkins/deploy
                    tfsec
                '''
            }
        }

        stage('Deploy'){
            agent {
                docker {
                    image 'hashicorp/terraform:1.9'
                     args '--entrypoint="" --user="root" -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                }
            }
            steps {
                sh '''
                    # Output the AWS environment variables
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID" > junk2
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
                    
                    # Install AWS CLI
                    apk add --no-cache aws-cli
                    export AWS_DEFAULT_REGION=us-east-1

                    # Deploy Jenkins App
                    cd terraform
                    terraform init
                    terraform apply -var-file terraform.tfvars -auto-approve
                '''
            }
        }


        stage('Destroy'){
            agent {
                docker {
                    image 'hashicorp/terraform:1.9'
                     args '--entrypoint="" --user="root" -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                }
            }
            steps {
                sh '''
                    # Output the AWS environment variables
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID" > junk2
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
                    
                    # Install AWS CLI
                    apk add --no-cache aws-cli
                    export AWS_DEFAULT_REGION=us-east-1

                    # Deploy Jenkins App
                    cd terraform
                    terraform init
                    terraform destroy -auto-approve
                '''
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
