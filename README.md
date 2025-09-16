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

Perfect 👍 let’s walk **step by step from `Terraform Init & Apply`** in your Jenkinsfile.

---

### 🔹 Stage: **Terraform Init & Apply**

```groovy
stage('Terraform Init & Apply') {
    steps {
        dir('terraform') {   // adjust if your tf files are at root
            sh 'terraform init -input=false'
            sh 'terraform apply -auto-approve -input=false'
            // Save EC2 public IP to a file
            sh 'terraform output -raw instance_public_ip > ../ec2_ip.txt'
        }
    }
}
```

#### What happens here:

1. **`dir('terraform')`**

   * Tells Jenkins to change working directory into a folder called `terraform`.
   * You must have your `.tf` files inside this folder (or else adjust/remove it).

2. **`terraform init -input=false`**

   * Initializes Terraform working directory.
   * Downloads AWS provider plugin + sets up backend (S3/DynamoDB if configured).
   * `-input=false` ensures it won’t ask interactive questions (important for automation).

3. **`terraform apply -auto-approve -input=false`**

   * Creates your infra (VPC, EC2, etc).
   * `-auto-approve` skips manual confirmation.
   * After this, your new EC2 instance is provisioned.

4. **`terraform output -raw instance_public_ip > ../ec2_ip.txt`**

   * Reads Terraform **output variable** named `instance_public_ip`.
   * `-raw` removes quotes/newlines.
   * Redirects it into a file (`ec2_ip.txt`) one level above current dir.
   * Now Jenkins has the EC2’s public IP stored locally, which will be used for Ansible.

---

### 🔹 Stage: **Generate Inventory & Inject Key**

```groovy
stage('Generate Inventory & Inject Key') {
    steps {
        script {
            def ec2Ip = readFile('ec2_ip.txt').trim()
            writeFile file: 'inventory.ini', text: """
[web]
${ec2Ip} ansible_user=ubuntu ansible_ssh_private_key_file=jenkins-key.pem
"""

            withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh-key',
                                              keyFileVariable: 'SSH_KEY_FILE',
                                              usernameVariable: 'SSH_USER')]) {
                sh '''
                  cp $SSH_KEY_FILE ./jenkins-key.pem
                  chmod 600 ./jenkins-key.pem
                '''
            }
        }
    }
}
```

#### What happens here:

1. **Read IP file**

   * Reads the EC2 public IP saved earlier by Terraform.
   * Example: `54.201.10.123`.

2. **Create `inventory.ini`**

   * Writes Ansible inventory file dynamically:

     ```ini
     [web]
     54.201.10.123 ansible_user=ubuntu ansible_ssh_private_key_file=jenkins-key.pem
     ```
   * `ubuntu` is the default username for Ubuntu AMIs.
   * `jenkins-key.pem` will be added in the next step.

3. **Inject Jenkins Credentials**

   * `withCredentials` securely loads the private SSH key stored in Jenkins credentials (`jenkins-ssh-key`).
   * Copies it to workspace as `jenkins-key.pem`.
   * Fixes permission (`chmod 600`).
   * Now Ansible can use it to SSH into EC2.

---

### 🔹 Stage: **Run Ansible via Docker**

```groovy
stage('Run Ansible via Docker') {
    steps {
        sh '''
          docker run --rm \
            -v "$PWD":/ansible \
            -w /ansible \
            williamyeh/ansible:alpine3 \
            ansible-playbook -i inventory.ini playbook.yml
        '''
    }
}
```

* Runs Ansible inside a temporary Docker container.
* Mounts your Jenkins workspace (`$PWD`) into `/ansible` inside the container.
* Executes:

  ```bash
  ansible-playbook -i inventory.ini playbook.yml
  ```
* This connects to the EC2 at the dynamic IP with the injected key.
* Configures your infra (install software, deploy apps, etc).

---

✅ So from `Terraform Init & Apply` onwards, the flow is:

1. Terraform provisions EC2 → saves public IP.
2. Jenkins dynamically creates inventory.ini with that IP.
3. Jenkins securely injects SSH key into workspace.
4. Ansible (via Docker) uses IP + key to configure EC2.

---

# ADDITIONAL INFO :

🔹 The -v "$PWD":/ansible part

-v in Docker means mount (share) a folder from host → into container.

$PWD = current directory on Jenkins workspace (the job folder where your code/terraform/inventory is).

/ansible = folder inside the container.

👉 So this means:
Everything in your Jenkins job’s workspace (Terraform files, inventory.ini, jenkins-key.pem, playbook.yml, etc) will be visible inside the container under /ansible.

🔹 The -w /ansible part

Sets the working directory inside the container to /ansible.

So when the container runs ansible-playbook -i inventory.ini playbook.yml,
it looks in /ansible/inventory.ini and /ansible/playbook.yml (which actually came from Jenkins workspace).


