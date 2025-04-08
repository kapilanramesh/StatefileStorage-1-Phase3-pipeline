pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Configure NGINX with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh-key', keyFileVariable: 'KEY')]) {
                    sh '''
                        ansible-playbook -i hosts.ini nginx-playbook.yml \
                        --private-key $KEY \
                        -u ubuntu
                    '''
                }
            }
        }
    }
}
