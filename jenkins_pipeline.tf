pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/kapilanramesh/terraform-bootstrap-codes.git'
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        sh 'terraform init'
        sh 'terraform apply -auto-approve'
      }
    }
  }
}
