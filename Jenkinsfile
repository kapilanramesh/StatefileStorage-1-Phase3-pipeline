pipeline {
    agent any

    environment {
        // Add Ansible's path for Jenkins to find it
        PATH = "/var/lib/jenkins/.local/bin:$PATH"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git(
                    url: 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git',
                    branch: 'main',
                    credentialsId: 'jenkins-ssh-key'
                )
            }
        }

        stage('Ansible Provisioning') {
            steps {
                sh '''
                    /var/lib/jenkins/.local/bin/ansible-playbook -i inventory.ini playbook.yml
                '''
            }
        }
    }
}
