# Busy Bee Coffee Web Store + CI/CD
Build a disposable, test EC2 instance running Amazon Linux 2 in Terraform that only allows SSH access.</br>
Test a script, test User Data (bootstrap) script, an AMI you've created in Packer, or whatever you need.</br>
`main.tf` is a flat Terraform configuration file that builds an EC2 instance with all dependencies necessary to SSH to it and lab.</br>
This build will create an SSH keypair on the machine you run this Terraform code from.</br>
A `terraform destroy` will nuke the instance, the VPC, the SSH keypair, and everything created from this build.

## Prerequisites
- Install Terraform on your machine
- Install Docker on your machine
- Install AWS CLI
- Configure AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config

## Instructions
- Clone this repo: `git clone https://github.com/mattburns-coalburns/disposable-ec2.git`
- `cd busybeecoffee`
- `terraform init`
- `terraform apply`
- Copy/paste the output into your terminal
- When you're done: `terraform destroy` 

# Resources in this lab
- VPC
- Subnet
- Internet Gateway
- Route Table
- Security Groups
- EC2 Instance
- RSA 4096 Keys

# Build Docker container
- `cd app/src`
- If you're not sure how to build a Docker image manually, go to ECR. Click View Push Commands. It will tell you the steps which go like this:
- Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI.: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <replace-with-account-ID>.dkr.ecr.<us-east-1>.amazonaws.com`
- Build your Docker image using the following command: `docker build -t ecs-busybee-home .`
- After the build completes, tag your image so you can push the image to this repository: `docker tag ecs-busybee-home:latest 764364320071.dkr.ecr.us-east-1.amazonaws.com/ecs-busybee-home:latest`
- Run the following command to push this image to your newly created AWS repository: `docker push 764364320071.dkr.ecr.us-east-1.amazonaws.com/ecs-busybee-home:latest`