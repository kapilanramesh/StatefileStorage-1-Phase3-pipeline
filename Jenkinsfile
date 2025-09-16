pipeline {
    agent any

    environment {
        TF_REPO = 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git'
        ANSIBLE_REPO = 'git@github.com:kapilanramesh/ansible-configs.git'
        SSH_KEY_ID = 'jenkins-ssh-key'  // stored in Jenkins credentials (type: SSH private key)
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

        stage('Terraform Init & Apply') {
            steps {
                sh '''
                    terraform init -input=false
                    terraform apply -auto-approve -input=false
                '''
            }
        }

        stage('Get EC2 Public IP') {
            steps {
                script {
                    def ec2_ip = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    echo "Provisioned EC2 Public IP: ${ec2_ip}"
                    writeFile file: "inventory.ini", text: "[web]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/ansible/jenkins-key.pem\n"
                }
            }
        }

        stage('Clone Ansible Repo') {
            steps {
                git credentialsId: 'jenkins-ssh-key',
                    url: "${ANSIBLE_REPO}",
                    branch: 'main'
            }
        }

        stage('Run Ansible via Docker') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "${SSH_KEY_ID}", keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        docker run --rm \
                          -v $WORKSPACE:/ansible \
                          -v $SSH_KEY:/ansible/jenkins-key.pem \
                          -w /ansible \
                          williamyeh/ansible:alpine3 \
                          ansible-playbook -i inventory.ini playbook.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed!"
        }
    }
}
