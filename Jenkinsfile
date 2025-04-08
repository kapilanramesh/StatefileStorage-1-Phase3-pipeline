pipeline {
    agent any

    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git credentialsId: 'jenkins-ssh-key',
                    url: 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git',
                    branch: 'main'
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
