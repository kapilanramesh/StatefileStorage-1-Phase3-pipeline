Thanks Kapilan! I’ve reviewed the 4 files from your **third repository**. Here’s a complete, clear, and beginner-friendly **README.md** for it, explaining each component and how everything fits together:

---

## 📦 Project: Jenkins + Ansible Web Server Provisioning

This project demonstrates a basic DevOps pipeline where a Jenkins pipeline is used to:

1. Clone a Terraform repository (can be extended for infrastructure setup)
2. Use **Ansible inside a Docker container** to provision a web server on a remote machine (like an EC2 instance)

---

## 📁 Files in This Repository

### 1. `inventory.ini`
Defines the remote server(s) where Ansible will run the playbook.

```ini
[web]
65.0.6.230 ansible_user=ubuntu ansible_ssh_private_key_file=jenkins-key.pem
```

- **65.0.6.230**: IP address of the target server (e.g., AWS EC2 instance)
- **ansible_user=ubuntu**: SSH login user
- **ansible_ssh_private_key_file**: Path to the private key used to SSH into the server. In this case, it's `jenkins-key.pem`, which is expected to be available in the Jenkins server.

---

### 2. `playbook.yml`
Ansible playbook to provision a web server.

```yaml
- name: Provision web server
  hosts: web
  become: yes
  tasks:
    - name: Update APT cache
      apt:
        update_cache: yes

    - name: Install NGINX
      apt:
        name: nginx
        state: present

    - name: Start NGINX service
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create index.html
      copy:
        dest: /var/www/html/index.html
        content: "<h1>Welcome to the Web Server provisioned by Ansible!</h1>"
```

🛠️ What this playbook does:
- Updates the package index on the server
- Installs **NGINX**
- Ensures NGINX is running and enabled on boot
- Creates a simple `index.html` landing page

---

### 3. `Jenkinsfile.txt`
This defines a Jenkins Pipeline to automate the provisioning process.

#### 📌 Stages:

```groovy
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
```

#### 🔍 Breakdown:
- **TF_REPO**: Holds the Terraform Git repository URL. (Terraform part not used directly here but ready to integrate)
- **Clean Workspace**: Deletes old files from the Jenkins job workspace
- **Clone Terraform Repo**: Clones the Terraform repo using an SSH key stored in Jenkins credentials
- **Ansible Provisioning**: 
  - Runs Ansible from a Docker container (`williamyeh/ansible:alpine3`)
  - Mounts Jenkins workspace and SSH key into Docker
  - Executes the playbook using the `inventory.ini` file

---

## 🔧 Prerequisites

- Jenkins server with Docker installed
- Jenkins credential with ID `jenkins-ssh-key` (SSH private key)
- Remote server (e.g., EC2) with:
  - Public IP
  - SSH access with the private key
- Ansible-compatible OS on the remote (like Ubuntu)

---

## 🚀 How to Use

1. Upload the contents of this repo into a Jenkins job workspace.
2. Ensure `jenkins-key.pem` exists in `/var/lib/jenkins/`.
3. Add your SSH private key in Jenkins > Manage Credentials with ID `jenkins-ssh-key`.
4. Run the Jenkins job.
5. Access the web server via browser:  
   `http://65.0.6.230`

---

## 📌 Notes

- You can extend the pipeline to run **Terraform** commands in earlier stages.
- Using Dockerized Ansible ensures no dependency issues on the Jenkins host.
- This is ideal for learning Jenkins + Ansible + Docker integration.

---

