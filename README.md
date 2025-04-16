# ✅ **CI/CD Web Server Provisioning using Jenkins, Ansible, Terraform (Dockerized)**

## 📄 **Overview**

This project automates the provisioning of an EC2 web server on AWS using **Terraform** for infrastructure, **Ansible** for configuration, and **Jenkins** for CI/CD pipeline execution using Docker.

---

## 🧱 **Technology Stack**

- **Terraform** – Creates EC2 instance & networking
- **Ansible** – Installs NGINX & configures web server
- **Jenkins** – Automates the whole process
- **Docker** – Runs Ansible inside a container

---

## 📁 **File Summary**

| File Name              | Purpose |
|------------------------|---------|
| `Jenkinsfile`          | Jenkins pipeline script for full automation |
| `inventory.ini`        | Lists target server IP and SSH access |
| `playbook.yml`         | Ansible playbook to configure the EC2 instance |
| `ansible.cfg`          | Tells Ansible which inventory file to use |

---

## 🔧 **Detailed Breakdown**

### 🔹 1. `Jenkinsfile` – Jenkins Pipeline

```groovy
pipeline {
    agent any
```
➡ Tells Jenkins to run this pipeline on any available agent (worker machine).

```groovy
    environment {
        TF_REPO = 'git@github.com:kapilanramesh/terraform-bootstraps-Proj-2.git'
    }
```
➡ Declares a variable pointing to your Terraform repo (used in the clone stage).

---

#### ✅ Stage 1 – Clean Jenkins Workspace
```groovy
stage('Clean Workspace') {
    steps {
        cleanWs()
    }
}
```
➡ Deletes all previous files from the Jenkins workspace to avoid conflicts.

---

#### ✅ Stage 2 – Clone Terraform Repository
```groovy
stage('Clone Terraform Repo') {
    steps {
        git credentialsId: 'jenkins-ssh-key',
            url: "${TF_REPO}",
            branch: 'main'
    }
}
```
➡ Clones the Terraform project from GitHub using the provided SSH key (`jenkins-ssh-key`).

---

#### ✅ Stage 3 – Run Ansible via Docker
```groovy
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
```

- ✅ Launches an **Ansible container** using the lightweight `williamyeh/ansible:alpine3` image.
- ✅ Mounts:
  - Jenkins workspace as working directory.
  - SSH private key (`jenkins-key.pem`) to connect to EC2.
- ✅ Runs `ansible-playbook` using:
  - `inventory.ini` → defines the EC2 target
  - `playbook.yml` → contains all server setup tasks

---

### 🔹 2. `inventory.ini` – Server Info

```ini
[web]
65.0.6.230 ansible_user=ubuntu ansible_ssh_private_key_file=jenkins-key.pem
```

➡ Defines the **target server** under the `web` group:
- IP: `65.0.6.230`
- SSH username: `ubuntu` (standard for Ubuntu EC2)
- SSH key: `jenkins-key.pem` (must exist in Jenkins workspace)

---

### 🔹 3. `ansible.cfg` – Ansible Config

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
```

➡ Tells Ansible:
- Use `inventory.ini` file as host list
- Disable host key checking to avoid prompt during first SSH (safer in CI/CD)

---

### 🔹 4. `playbook.yml` – Provisioning Logic

```yaml
- name: Provision web server
  hosts: web
  become: yes
  tasks:
```
➡ Runs tasks on `web` group using **sudo** (`become: yes`)

---

#### ✅ Task 1: Update Ubuntu
```yaml
- name: Update APT cache
  apt:
    update_cache: yes
```
➡ Runs `sudo apt update` – updates package list

---

#### ✅ Task 2: Install NGINX
```yaml
- name: Install NGINX
  apt:
    name: nginx
    state: present
```
➡ Installs the latest version of **NGINX web server**

---

#### ✅ Task 3: Start NGINX
```yaml
- name: Start NGINX service
  service:
    name: nginx
    state: started
    enabled: yes
```
➡ Starts and enables NGINX so it runs even after reboot

---

#### ✅ Task 4: Add a Custom Homepage
```yaml
- name: Create index.html
  copy:
    dest: /var/www/html/index.html
    content: "<h1>Welcome to the Web Server provisioned by Ansible!</h1>"
```
➡ Replaces default page with your **custom welcome message**

---

## 🚀 **How the Entire Flow Works**

1. **Terraform** provisions the EC2 instance.
2. **Jenkins** clones the Terraform repo and triggers provisioning.
3. **Ansible** (inside Docker) connects to EC2 and:
   - Installs NGINX
   - Sets up homepage
4. Access your website at:  
   `http://<EC2 Public IP>` → You'll see your custom message!

---

## ✅ **Best Practices Followed**

- SSH key secured using Jenkins credentials
- Docker isolates Ansible environment
- CI/CD fully automated using Jenkinsfile
- Custom index.html to verify server provisioning success

---
