#!/bin/bash

# ===============================
# Rancher Installation Script
# For RHEL / Amazon Linux 2023
# ===============================

set -e

echo "Updating system..."
sudo dnf update -y

echo "Installing Docker..."
sudo dnf install -y docker

echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding ec2-user to docker group..."
sudo usermod -aG docker ec2-user

echo "Creating Rancher data directory..."
sudo mkdir -p /opt/rancher
sudo chown -R ec2-user:ec2-user /opt/rancher

echo "Applying docker group without logout..."

# Apply new group and run docker inside newgrp shell
newgrp docker <<EONG

echo "Running Rancher container..."
docker run -d \
  --restart=unless-stopped \
  --privileged \
  -p 80:80 \
  -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  --name rancher \
  --hostname rancher \
  rancher/rancher:latest

EONG

echo "====================================="
echo "Rancher installation completed!"
echo "Access Rancher at: https://<your-server-ip>"
echo "====================================="
