pipeline {
    agent any

    environment {
        TF_REPO = 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git'
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
                    url: "${TF_REPO}",
                    branch: 'main'
            }
        }

        stage('Ansible Provisioning (via Docker)') {
            steps {
                script {
                    sh '''
                        docker run --rm \
                          -v /var/lib/jenkins/workspace/complete-setup:/ansible \
                          -v /var/lib/jenkins/jenkins-key.pem:/ansible/jenkins-key.pem \
                          -w /ansible \
                          williamyeh/ansible:alpine3 \
                          ansible-playbook -i inventory.ini playbook.yml
                    '''
                }
            }
        }
    }
}
