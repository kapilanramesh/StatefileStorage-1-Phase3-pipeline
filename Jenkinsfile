pipeline {
    agent any

    environment {
        TF_REPO = 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git'
        TF_BRANCH = 'main'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git branch: "${env.TF_BRANCH}", credentialsId: 'jenkins-ssh-key', url: "${env.TF_REPO}"
            }
        }

        stage('Ansible Provisioning (via Docker)') {
            steps {
                script {
                    sh '''
                    docker run --rm -v $PWD:/ansible -w /ansible williamyeh/ansible:alpine3 \
                    ansible-playbook -i inventory.ini playbook.yml
                    '''
                }
            }
        }
    }
}
