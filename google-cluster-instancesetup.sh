curl -sS https://webinstall.dev/k9s | bash

✅ Correct & recommended way to install k9s (works 100%)
🔹 Install via official Webi installer (fastest)

curl -sS https://webinstall.dev/k9s | bash
Then reload your shell:

source ~/.bashrc
Verify:

k9s version

✅ Alternative: Manual binary install (no installer)

curl -LO https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

 helm install prometheus-stack prometheus-community/kube-prometheus-stack --namespace=monitoring --create-namespace


grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password demo@123

From <https://community.grafana.com/t/admin-password-reset/19455> 

Ubuntu24




############Install docker in ubuntu 22#####################






✅ Step-by-step FIX (DO THESE IN ORDER)

1️⃣ REMOVE the old Kubernetes repo (critical)

sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/sources.list.d/kubernetes*.list
Verify it’s gone:

grep -R kubernetes-xenial /etc/apt/sources.list*
➡️ should return nothing

2️⃣ Clean APT cache

sudo apt clean
sudo apt update
At this point, the error should be gone.

3️⃣ Add the NEW official Kubernetes repo (pkgs.k8s.io)
Install prerequisites

sudo apt install -y apt-transport-https ca-certificates curl gpg
Add key

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
Add repo

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

4️⃣ Update APT (this MUST succeed)

sudo apt update
You should NOT see kubernetes-xenial anymore.

5️⃣ Install Kubernetes components

sudo apt install -y kubelet kubeadm kubectl

6️⃣ Hold versions (important)

sudo apt-mark hold kubelet kubeadm kubectl
Verify:

apt-mark showhold

7️⃣ Verify install

kubeadm version
kubelet --version
kubectl version --client

#######################

#!/usr/bin/env bash
set -e

echo "🔹 Installing required packages..."
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg

echo "🔹 Adding Kubernetes APT key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "🔹 Adding Kubernetes APT repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo "🔹 Updating APT cache (must succeed)..."
sudo apt update

echo "🔹 Installing Kubernetes components..."
sudo apt install -y kubelet kubeadm kubectl

echo "🔹 Holding Kubernetes package versions..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "✅ Kubernetes components installed and held successfully."

##########Need these steps to configure waeve-net pods###############

Please run thi sin the master node
sudo ufw allow 6443/tcp
sudo ufw reload



kubectl apply -f https://github.com/weaveworks/weave/releases/latest/download/weave-daemonset-k8s.yaml




0. Provisioning Nodes and Firewalls:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

0a. Kubernetes Cluster Nodes(3):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cloud: Google Compute Engine (GCE)
Master(1): 2 vCPUs - 4GB Ram  
Worker(2): 2 vCPUs - 2GB RAM
OS:     Ubuntu 22.04 , x86/64 ubuntu-2204-jammy-v2025

0b. Firewall Rules (Ingress): 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Master Node: 2379,6443,10250,10251,10252 
Worker Node: 10250,30000-32767

Turn on http/https for weave-net download when setting up pod

0c. NOT Mandatory. For better visibility.
-----------------------------------------
Add below lines to ~/.bashrc
Master Node:
PS1="\e[0;33m[\u@\h \W]\$ \e[m "

Worker Node:
PS1="\e[0;36m[\u@\h \W]\$ \e[m "


1a) Disable SWAP:
~~~~~~~~~~~~~~~~~
swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab


1b) Bridge Traffic:
~~~~~~~~~~~~~~~~~~~
lsmod | grep br_netfilter 
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system



##################Complete docker and k8s script  12/19/2025##########################
#!/usr/bin/env bash
set -e

echo "=============================="
echo " Updating system"
echo "=============================="
sudo apt update
sudo apt upgrade -y

echo "=============================="
echo " Installing base dependencies"
echo "=============================="
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  gpg \
  lsb-release

# --------------------------------------------------
# Docker installation
# --------------------------------------------------
echo "=============================="
echo " Installing Docker"
echo "=============================="

echo " Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo " Adding Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo " Updating APT cache for Docker..."
sudo apt update

echo " Installing Docker Engine..."
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo " Verifying Docker installation..."
docker --version

# Optional but recommended
echo " Enabling Docker at boot..."
sudo systemctl enable docker
sudo systemctl start docker

# --------------------------------------------------
# Kubernetes installation
# --------------------------------------------------
echo "=============================="
echo " Installing Kubernetes (v1.30)"
echo "=============================="

echo " Adding Kubernetes GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo " Adding Kubernetes repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo " Updating APT cache for Kubernetes (must succeed)..."
sudo apt update

echo " Installing Kubernetes components..."
sudo apt install -y kubelet kubeadm kubectl

echo " Holding Kubernetes package versions..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "=============================="
echo " Installation completed successfully"
echo "=============================="


echo "=============================="
echo " Stop kubelet and containerd"
echo "=============================="

sudo systemctl stop kubelet
sudo systemctl stop containerd

sudo rm -f /etc/containerd/config.toml
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reexec
sudo systemctl restart containerd
sudo systemctl enable containerd
echo "=============================="
echo " Successfully install kubelet and containerd"
echo "=============================="



###############Master node script################
#!/usr/bin/env bash
set -e

echo "=============================="
echo " Initializing Kubernetes Master"
echo "=============================="

# Initialize the cluster
# You may add --pod-network-cidr if using a different CNI
sudo kubeadm init

echo "=============================="
echo " Configuring kubectl for current user"
echo "=============================="

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "=============================="
echo " Installing Weave CNI (Pod Network)"
echo "=============================="

kubectl apply -f https://github.com/weaveworks/weave/releases/latest/download/weave-daemonset-k8s.yaml

echo "=============================="
echo " Installing Weave CNI completed"
echo "=============================="



