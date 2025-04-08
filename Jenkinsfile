pipeline {
    agent any

    environment {
        TF_VAR_region = 'ap-south-1'
    }

    options {
        skipDefaultCheckout(true) // prevent auto-checkout to allow manual workspace control
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Pipeline Repo') {
            steps {
                git url: 'https://github.com/kapilanramesh/Jenkins-pipelines', branch: 'main'
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                sh '''
                    git clone https://github.com/your-username/terraform-bootstraps-Proj-2.git
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform-bootstraps-Proj-2') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-bootstraps-Proj-2') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Provisioning') {
            steps {
                sh '''
                    ansible-playbook -i inventory.ini playbooks/setup-nginx.yml
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo '✅ Provisioning complete!'
        }
        failure {
            echo '❌ Something went wrong.'
        }
    }
}
