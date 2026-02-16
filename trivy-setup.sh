#!/bin/bash
set -e

echo "=== Installing Trivy on RHEL/CentOS/Rocky/AlmaLinux ==="

# 1️⃣ Import GPG key
echo "Importing Trivy GPG key..."
sudo rpm --import https://aquasecurity.github.io/trivy-repo/rpm/public.key

# 2️⃣ Add Trivy repository
echo "Adding Trivy repository..."
sudo tee /etc/yum.repos.d/trivy.repo > /dev/null <<EOF
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF

# 3️⃣ Install Trivy
if command -v dnf &> /dev/null; then
    echo "Detected dnf package manager. Installing Trivy..."
    sudo dnf install -y trivy
elif command -v yum &> /dev/null; then
    echo "Detected yum package manager. Installing Trivy..."
    sudo yum install -y trivy
else
    echo "Error: Neither yum nor dnf found. Cannot install Trivy."
    exit 1
fi

# 4️⃣ Verify installation
echo "Verifying Trivy installation..."
trivy --version

echo "✅ Trivy installation completed successfully!"
