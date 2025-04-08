pipeline {
    agent any

    environment {
        TF_VAR_public_key = credentials('jenkins-ssh-key')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Configuration') {
            steps {
                sh '''
                    git clone https://github.com/kapilanramesh/terraform-bootstraps-Proj-2 terraform-config
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform-config') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-config') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                sh '''
                    echo "[web]" > inventory
                    terraform -chdir=terraform-config output -raw public_ip >> inventory
                '''
            }
        }

        stage('Configure NGINX with Ansible') {
            steps {
                sh '''
                    ansible-playbook -i inventory playbook.yml
                '''
            }
        }
    }
}
