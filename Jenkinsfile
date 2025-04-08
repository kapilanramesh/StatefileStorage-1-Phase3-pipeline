pipeline {
    agent any

    environment {
        // Ensure Ansible uses our config
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
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
                sh 'ansible-playbook -i inventory.ini playbook.yml'
            }
        }
    }
}
