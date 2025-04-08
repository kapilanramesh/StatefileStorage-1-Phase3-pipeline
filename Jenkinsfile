pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout Infra Code') {
      steps {
        git 'https://github.com/your-username/my-infra-project.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan & Apply') {
      steps {
        sh 'terraform plan -var-file="terraform.tfvars"'
        sh 'terraform apply -auto-approve -var-file="terraform.tfvars"'
      }
    }
  }
}
