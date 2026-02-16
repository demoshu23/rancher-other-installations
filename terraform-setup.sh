#!/bin/bash

# ===============================
# Terraform Install Script for RHEL
# ===============================

# 1. Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo yum update -y
sudo yum install -y wget unzip

# 2. Set Terraform version (change this if a newer version is available)
TERRAFORM_VERSION="1.5.7"
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# 3. Download Terraform
echo "Downloading Terraform v${TERRAFORM_VERSION}..."
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}" -O terraform.zip

# 4. Unzip the package
echo "Unzipping Terraform..."
unzip terraform.zip

# 5. Move the binary to /usr/local/bin
echo "Installing Terraform to /usr/local/bin..."
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform

# 6. Cleanup zip file
rm terraform.zip

# 7. Verify installation
echo "Terraform installation complete. Version:"
terraform version
