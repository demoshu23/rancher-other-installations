# #!/bin/bash

# # ===============================
# # Rancher Installation Script
# # For RHEL / Amazon Linux 2023
# # ===============================

# set -e

# echo "Updating system..."
# sudo dnf update -y

# echo "Installing Docker..."
# sudo dnf install -y docker

# echo "Starting Docker service..."
# sudo systemctl start docker
# sudo systemctl enable docker

# echo "Adding ec2-user to docker group..."
# sudo usermod -aG docker ec2-user

# echo "Creating Rancher data directory..."
# sudo mkdir -p /opt/rancher
# sudo chown -R ec2-user:ec2-user /opt/rancher

# echo "Applying docker group without logout..."

# # Apply new group and run docker inside newgrp shell
# newgrp docker <<EONG

# echo "Running Rancher container..."
# docker run -d \
#   --restart=unless-stopped \
#   --privileged \
#   -p 80:80 \
#   -p 443:443 \
#   -v /opt/rancher:/var/lib/rancher \
#   --name rancher \
#   --hostname rancher \
#   rancher/rancher:v2.13.1


# EONG

# echo "====================================="
# echo "Rancher installation completed!"
# echo "Access Rancher at: https://<your-server-ip>"
# echo "====================================="

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

# Wait for Docker daemon to be fully ready
echo "Waiting for Docker to be ready..."
sleep 10

echo "Adding ec2-user to docker group..."
sudo usermod -aG docker ec2-user

# Small delay to ensure group modification is applied
sleep 5

echo "Creating Rancher data directory..."
sudo mkdir -p /opt/rancher
sudo chown -R ec2-user:ec2-user /opt/rancher

echo "Applying docker group without logout..."

# Apply new group and run docker inside newgrp shell
newgrp docker <<EONG

echo "Waiting before running Rancher..."
sleep 5

echo "Running Rancher container..."
docker run -d \
  --restart=unless-stopped \
  --privileged \
  -p 80:80 \
  -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  --name rancher \
  --hostname rancher \
  rancher/rancher:v2.13.1

echo "Waiting for Rancher to initialize..."
sleep 30

EONG

echo "====================================="
echo "Rancher installation completed!"
echo "Rancher may take 2-3 minutes to fully initialize."
echo "Access Rancher at: https://<your-server-ip>"
echo "====================================="
