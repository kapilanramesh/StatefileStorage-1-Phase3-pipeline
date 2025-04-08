pipeline {
    agent any

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git credentialsId: 'jenkins-ssh-key', url: 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git'
            }
        }

        stage('Ansible Provisioning (via Docker)') {
            steps {
                script {
                    // Pull and run Ansible in Docker
                    sh '''
                    docker run --rm \
                        -v $PWD:/ansible \
                        -v /var/lib/jenkins/.ssh:/root/.ssh \
                        -w /ansible \
                        williamyeh/ansible:alpine3 \
                        ansible-playbook -i inventory.ini playbook.yml
                    '''
                }
            }
        }
    }
}
