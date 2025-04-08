pipeline {
  agent any

  environment {
    TF_VAR_region = 'ap-south-1'
  }

  stages {

    stage('Clone Terraform Configuration') {
      steps {
        // Clone the actual Terraform repository into terraform-config directory
        sh 'git clone https://github.com/kapilanramesh/terraform-bootstraps-Proj-2 terraform-config'
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform-config') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform-config') {
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Generate Ansible Inventory') {
      steps {
        dir('terraform-config') {
          sh '''
            echo "[webserver]" > ../ansible/hosts.ini
            echo "$(terraform output -raw public_ip) ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa" >> ../ansible/hosts.ini
          '''
        }
      }
    }

    stage('Configure NGINX with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/hosts.ini ansible/playbook.yml'
      }
    }
  }
}
