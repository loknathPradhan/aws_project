AWS Infrastructure Provisioning with Terraform

This project provisions a scalable, secure, and production-ready AWS infrastructure using Terraform. It leverages reusable modules, environment-based configurations, and a clean architectural approach with support for multi-AZ deployment, auto-scaling, and secure access to private EC2 instances.

📚 Overview
🔧 Infrastructure Highlights

    1. High Availability: Resources are distributed across two Availability Zones (AZs) for fault tolerance.

    2. Modular Design: Each component (VPC, ALB, Subnets, NAT, Security Groups, etc.) is encapsulated in reusable Terraform modules.

    3. Remote Backend: Uses Amazon S3 for storing Terraform state and DynamoDB for state locking.

    4. Public & Private Subnets: Public subnets for NAT, Bastion, and ALB; Private subnets for backend EC2 instances.

    5. Application Load Balancer (ALB): Routes traffic to EC2 instances in private subnets via Target Groups.

    6. Auto Scaling Group (ASG): Ensures high availability and scalability of backend EC2 instances.

    7. Secure SSH Access: Bastion host provisioned in the public subnet to access private EC2 instances via SSH.

    8. User Data Automation: Installs and configures a simple NGINX server as part of EC2 instance provisioning.

    9. Environment Support: Supports multiple environments (e.g., dev, staging, prod) using separate configurations.




![Screenshot 2025-05-17 084925](https://github.com/user-attachments/assets/5ad0e507-b246-4860-8716-c6f68f490158)


📂 Project Structure

![image](https://github.com/user-attachments/assets/4e887f88-70d1-4423-9d8d-2cdf5a421e12)



🛠️ Pre-Requisites (Manual Setup Before Terraform Apply)
  Before running the infrastructure provisioning:

  1. Create S3 Bucket and DynamoDB Table

    Used as the remote backend for Terraform state and locking.
    
    you can run the s3_and_db.sh file

  2. Set Up Terraform Backend

    Configure backend in environments/dev/backend.tf.


✅ Final Flow of Resource Creation – Terraform Project Overview
This Terraform setup follows a layered, dependency-aware approach to building AWS infrastructure, ensuring each resource is created in the correct order to avoid failure and promote modularity and reusability.

🔹 1. VPC + Networking Layer (Core Infrastructure)
These foundational network components must be created first, as nearly every other AWS resource depends on them.

Components:
aws_vpc – Defines the virtual network

aws_subnet – Public and private subnets, spanning 2 Availability Zones (AZs)

aws_internet_gateway – For internet access to public subnets

aws_nat_gateway – For private subnet internet access via NAT

aws_eip – Elastic IP for the NAT gateway

aws_route_table and aws_route_table_association – Routing setup for public/private access

Output Exports:

VPC ID

Subnet IDs (public/private)

Route table IDs

                           
Legend:
- Public Subnets have routes to Internet Gateway (IGW)
- NAT Gateways are in Public Subnets (one per AZ)
- Private Subnets route 0.0.0.0/0 traffic to respective NAT Gateway
- IGW handles all outbound internet traffic
- VPC encloses everything (subnets, NATs, routes, etc.)




🔹 2. Security Groups (SGs)
Security groups are created early so that they can be reused and attached to:

Application Load Balancer (ALB)

EC2 instances (via Auto Scaling Group)

SG Definitions:
ALB SG:

Inbound: HTTP (80) and HTTPS (443) from 0.0.0.0/0

Outbound: Allow all or restrict to EC2 ports

EC2 SG (for ASG):

Inbound: Application port (e.g., 8080) from ALB SG

Outbound: Allow all (or restrict to app requirements)

🔹 3. Application Load Balancer (ALB)
ALB is deployed into public subnets across both AZs and will route traffic to private EC2 instances managed by the ASG.

Components:
aws_lb – ALB resource

aws_lb_target_group – Points to EC2 instances

aws_lb_listener – Handles port forwarding (e.g., 80/443 → target group)

Depends on:

Public subnet IDs

ALB SG

EC2 target group (needed before ASG)

🔹 4. Launch Template
This defines how EC2 instances are configured when launched by the ASG.

Configuration:
AMI ID (usually passed via variables or data source)

Instance type (e.g., t3.micro)

Security Group – EC2 SG

User Data (bootstrap script, optional)

Used by: Auto Scaling Group

🔹 5. Auto Scaling Group (ASG)
The ASG is deployed across private subnets and manages EC2 instance scaling.

Configuration:
Uses the Launch Template

Deployed in private subnets (AZ 1 and AZ 2)

Connected to ALB Target Group

Min/Max/Desired instance counts

Important: ALB target group must exist before creating ASG.


🔹 6. Remote State Management (S3 + DynamoDB)
To ensure consistent deployment and state locking:

S3 Bucket: Stores .tfstate files

DynamoDB Table: Handles state locking

Configured via backend.tf in each environment (environments/dev/backend.tf), using:

hcl
Copy
Edit
terraform {
  backend "s3" {
    bucket         = "your-terraform-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

🔹 7. (Optional) Bastion Server & SSH Access
After the infrastructure is up, you can create a Bastion Server in the public subnet. This will allow you to SSH into the private EC2 instances within the Auto Scaling Group. Once inside, you can install a simple NGINX server on the instance for testing or demonstration purposes.



Terraform Commands Reference

Below are the standard Terraform commands used to manage this infrastructure, specifically targeting the dev environment:

# 🔹 Initialize the Terraform working directory and configure the backend
 terraform init -backend-config=../environments/dev/backend.tf

# 🔹 Validate the Terraform configuration files
terraform validate

# 🔹 Preview the changes before applying
terraform plan -var-file=../environments/dev/terraform.tfvars

# 🔹 Apply the infrastructure changes
terraform apply -var-file=../environments/dev/terraform.tfvars

# 🔹 Destroy all provisioned resources
terraform destroy -var-file=../environments/dev/terraform.tfvars

📌 You can replace dev with staging or prod to target other environments.

________________________________________________________________________________________________________________________________________
