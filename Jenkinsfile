pipeline {
    agent any

    environment {
        TF_REPO = 'git@github.com:kapilanramesh/StatefileStorage-1-Phase1.git'       // Terraform for Phase 1
        TF_REPO_PHASE2 = 'git@github.com:kapilanramesh/StatefileStorage-1-Phase2.git' // Terraform for Phase 2 + Ansible configs
        TF_REPO_PHASE3 = 'git@github.com:kapilanramesh/StatefileStorage-1-Phase3-pipeline.git' // Pipeline repo if needed
        SSH_KEY_ID = 'jenkins-ssh-key'  // Jenkins credential (SSH private key)
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                git credentialsId: "${SSH_KEY_ID}",
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

        stage('Get EC2 Public IP & Generate Inventory') {
            steps {
                script {
                    def ec2_ip = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "Provisioned EC2 Public IP: ${ec2_ip}"

                    // Generate dynamic inventory for Ansible
                    writeFile file: "inventory.ini", text: "[web]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/ansible/jenkins-key.pem\n"
                }
            }
        }

        stage('Clone Ansible Repo (Phase 2)') {
            steps {
                git credentialsId: "${SSH_KEY_ID}",
                    url: "${TF_REPO_PHASE2}",
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
