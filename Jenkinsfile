pipeline {
    agent any

    environment {
        TF_REPO = "https://github.com/your-username/terraform-bootstraps-Proj-2.git"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git url: "${env.TF_REPO}", branch: 'main'
            }
        }

        stage('Ansible Provisioning') {
            steps {
                sh '''
                    ansible-playbook -i inventory.ini playbook.yml
                '''
            }
        }
    }
}
