# shibinnetworks

CI/CD Pipeline to Azure Infrastructure and App Deployment

This repository includes the infrastructure and application code required to deploy a web application using Flask on Azure with Terraform, Docker, and Ansible. This repository automates the process of provisioning infrastructure, building Docker images, and pushing into Azure Container Registry (ACR).

## Overview

The CI/CD pipeline is supposed to do the following:

1. Provision infrastructure in Azure using Terraform.
2. Azure VM creation, networking, and Azure Container Registry Creation.
3. Dockerization of a Flask web application.
4. Push the created Docker image to Azure ACR.
5. Deployment using Ansible: It configures the infrastructure and installs the required software on the created VM.

This pipeline would trigger on every push on the main branch and automate everything from creating the infrastructure to deploying it.

## Prerequisites

Before running the pipeline make sure that the following are prepared:

- **GitHub Secrets** for sensitive data like Azure credentials and passwords, which includes:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_TENANT_ID`
  - `ADMIN_PASSWORD`

- **Terraform**, **Docker**, and **Ansible** installed locally in case you need to do run tests manually or deploy app outside pipeline.
## Directory Structure

├── app │ ├── Dockerfile # Dockerfile to create the Flask app image │ └── static/ # HTML content for the Flask app ├── infrastructure │ ├── main.tf # Terraform configuration for Azure resources │ ├── outputs.tf # Terraform outputs for VM, ACR │ └── variables.tf # Terraform variables ├── .github │ └── workflows # GitHub Actions workflow for CI/CD ├── ansible │ └── inventory.ini # Ansible inventory file │ └── playbook.yml # Ansible playbook to configure the VM └── README.md # This file


Overview of Workflow

This is the list of the steps that are run in the GitHub Actions CI/CD pipeline:

1. **Provision the Infrastructure Using Terraform**:
	* Initializes and applies the Terraform configuration in the `infrastructure/` directory.
	* Resources provisioned:
		+ Azure Resource Group
		+ Virtual Network and Subnet
		+ Public IP for the VM
- Network Security Group NSG
     - Linux VM
     - ACR

2. **Ansible Configure Azure VM**:
   - Ansible configures the newly created VM by:
    - Deploying Docker on the VM
    - Enabling the VM to deploy the Dockerized application
- Setup Flask application on VM

3. **Build and Push Docker Image to Azure ACR**:
   - In this step, this pipeline will build a Docker image of the Flask application from the `Dockerfile` located in the `app/` directory.
   - Then it tags the image by using the Git commit hash that fired this pipeline and pushes it to the Azure Container Registry (ACR).

4. **Deploy Docker Image from ACR to VM:**
It pulls the Docker image deployed in the ACR and runs it inside the Azure VM.

## GitHub Actions Workflow

The `.github/workflows/main.yml` file contains the steps that'll be executed for the CI/CD pipeline. Key ones include the following:

* **Checkout code**: This step checks out the code in the repository.
* **Terraform setup and provisioning**: This step initializes and applies the Terraform configuration to provision Azure resources.
- **Ansible configuration**: An Ansible playbook run to configure the VM to install Docker and to prepare the application
- **Build and push Docker image**: Build Docker image for Flask application and then push it to ACR
- **Deploy application**: Application will be deployed on the Azure VM by pulling its Docker image from ACR

## Terraform Configuration

The above `infrastructure/main.tf` defines all the Azure resources using Terraform. Resources created here include:

**Resource Group**: `network-rg`
**Virtual Network and Subnet**
**Public IP**
**VM with SSH access**
**Network Security Group (NSG)** - to allow SSH traffic on port 22 and HTTP traffic on port 80
**Azure Container Registry (ACR)**

### Example variables:
```hcl
variable "resource_group_name" {
  default = "network-rg"
}

variable "location" {
  default = "West US"
}

variable "vm_name" {
  default = "network-vm"
}

variable "admin_username" {
default = "azure_user"
}
Ansible setup
Prepare the azure vm using Ansible inventory file called ansible/inventory.ini and ansible playbook file called 	ansible/playbook.yml Inventory.ini has details about the machines to connect to the virtual machine using ssh and the playbook does the installation of docker and preparation of the application.
docker config
The Dockerfile in the app/ directory specifies how the Flask application is packaged into a Docker Image. In this, an official HTTPD (Apache) Docker image is pulled for running the HTML files.

This is an example of the README.md file that describes the overview and installation instructions for the complete infrastructure and application pipeline, with Terraform, Docker, and Ansible integrations.

markdown

# Azure Infrastructure and App CI/CD Pipeline

This repository provides infrastructure and application code, through which one can deploy a Flask web application to Azure using Terraform, Docker, and Ansible. The repository automates infrastructure provisioning, Docker image building, and its deployment to Azure Container Registry (ACR).

## Overview

The CI/CD will be designed to:

1. Provision infrastructure on Azure using Terraform.
2. Setup an Azure Virtual Machine (VM), networking and an Azure Container Registry (ACR).
3. Build a Docker image from a Flask web application.
4. Push the built Docker image into Azure ACR.
5. Deployment with Ansible to configure the infrastructure to prepare the VM and software setup.

The following pipeline is only triggered for pushes onto the `main` branch; therefore, infrastructure provision to deployment is automated.

## Prerequisites

Before running the pipeline, make sure you have the following:

- **GitHub Secrets** voor sensitive data als Azure credentials en passwords:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_TENANT_ID`
  - `ADMIN_PASSWORD`

- **Terraform**, **Docker**, and **Ansible** on the local system if performing tests are done outside of pipeline testing or deploy the app outside of pipeline.

## Directory Structure

└── app │   ├── Dockerfile # Dockerfile to build the Flask app image. │   └── static/ # HTML content for the Flask application. ├── infrastructure │   ├── main.tf # Terraform configuration for Azure resources. │   ├── outputs.tf # Terraform outputs for VM, ACR. │   └── variables.tf # Terraform variables. ├── .github │   └── workflows # GitHub Actions workflow for CI/CD. ├── ansible │   └── inventory.ini # Ansible inventory file. │   └── playbook.yml # Ansible playbook to configure the Virtual Machine. └── README.md # This file.



## Overview of Workflow

GitHub Actions CI/CD pipeline goes through the following stages of the pipeline:

1. **Provision the Infrastructure with Terraform**:
   - Initialises and applies the Terraform configuration in the `infrastructure/` directory.
   - Resources provisioned:
     - Azure Resource Group
     - Virtual Network and Subnet
     - Public IP for the VM
- Network Security Group (NSG)
     - Linux VM
     - ACR

2. **Azure VM Configuration using Ansible**:
   - The newly created VM will be configured using Ansible:
     - To install Docker on the VM
     - To configure the VM so it would be able to run the Dockerised application
- Setting up of the Flask app on the VM

3. **Build and Push Docker Image to Azure ACR**:
   - The pipeline builds the Flask application Docker image from the `Dockerfile` in the `app/` directory.
   - Tag the image with the Git commit hash and push to the Azure Container Registry (ACR).

4. **Deploy Docker Image from ACR to VM**:
The Docker image deployed is pulled from the ACR and run inside the Azure VM.

## GitHub Actions Workflow

The `.github/workflows/main.yml` describes the flow of the CI/CD. Let's discuss some key steps that are being executed by this pipeline:

* **Checkout code**: Checkout code from the repository
* **Terraform setup and provisioning**: Terraform set up and apply to provision the Azure resources.
- **Ansible configuration**: Run an Ansible playbook to configure the VM such that Docker is installed and the application is ready
- **Build and push Docker image**: To Build the Docker image for Flask application and push it to ACR
- **Deploy application**: Use the pulled Docker image from ACR to deploy the application to Azure VM

## Terraform Configuration

The `infrastructure/main.tf` defines the Azure resources using Terraform. Resources to be created include:

**Resource Group**: `network-rg`
**Virtual Network and Subnet**
**Public IP**
**VM with SSH access**
**Network Security Group (NSG)** allowing SSH -port 22- and HTTP -port 80- traffic
**Azure Container Registry (ACR)**

### Example variables:
```hcl
variable "resource_group_name" {
  default = "network-rg"
}

variable "location" {
  default = "West US"
}

variable "vm_name" {
  default = "network-vm"
}

variable "admin_username" {
default = "azure_user"
}
Inventory for Ansible Configuration
The files needed to configure the Azure VM using Ansible are ansible/inventory.ini and ansible/playbook.yml. This inventory.ini file will provide the details of the connection of the VM using SSH, while playbook.yml will install Docker and configure the application.

Here is a sample inventory:

azure-vm ansible_host=52.174.50.220 ansible_user=azure_user ansible_ssh_private_key_file=server_key.pem ansible_python_interpreter=/usr/bin/python3.9

[all:vars]
ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh_common_args='-o ServerAliveInterval=90 -o ServerAliveCountMax=4'
Example Playbook:

---
- name: Set up Docker and deploy Flask app
  hosts: web
  tasks:
- name: Install Docker
      become: yes
      apt:
        name: docker.io
        state: present

    - name: Pull Docker image from ACR
      docker_image:
        name: "{{ acr_server }}/flask-app:latest"
source: pull

    - name: Start Flask app container
      docker_container:
        name: flask_app
        image: "{{ acr_server }}/flask-app:latest"
        state: started
        ports:
- "80:80"
Docker Configuration
The Dockerfile in the app/ directory indicates how the Flask application is packaged into a Docker image. This uses an official HTTPD Apache image for serving the HTML files.

Sample Dockerfile:
Dockerfile

FROM httpd:alpine

WORKDIR /usr/local/apache2/htdocs/


EXPOSE 8080

CMD ["httpd", "-D", "FOREGROUND"]
How to Run the Pipeline
Configure GitHub Secrets:

In your repository, navigate to Settings → Secrets.
Click on Add a new secret and add the following secrets :
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
ADMIN_PASSWORD
Push to main branch:

Push your changes into the main branch of the repository. Due to the CI/CD pipeline, this will trigger it, and it starts the provisioning of the infrastructure and the deployment of the application.
Monitor the workflow:

You can see what is going on with the pipeline in the "Actions" tab of your GitHub repository.
Conclusion
This pipeline automates infrastructure and application deployments on Azure using Terraform, Docker, and Ansible. It provides a step-by-step explanation of how to provision infrastructure from scratch and then deploy and run a Dockerized web application inside a virtual machine.
