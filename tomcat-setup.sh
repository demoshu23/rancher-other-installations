#!/usr/bin/env bash
set -euo pipefail

# -------- VARIABLES --------
TOMCAT_VERSION="10.1.18"
TOMCAT_USER="tomcat"
INSTALL_DIR="/opt/tomcat"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

echo "Installing Java..."
sudo dnf install -y java-17-openjdk wget

echo "Creating Tomcat user..."
sudo useradd -r -m -U -d ${INSTALL_DIR} -s /bin/false ${TOMCAT_USER} || true

echo "Downloading Tomcat ${TOMCAT_VERSION}..."
wget ${TOMCAT_URL}

echo "Extracting Tomcat..."
sudo mkdir -p ${INSTALL_DIR}
sudo tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${INSTALL_DIR} --strip-components=1

echo "Setting permissions..."
sudo chown -R ${TOMCAT_USER}:${TOMCAT_USER} ${INSTALL_DIR}
sudo chmod -R 755 ${INSTALL_DIR}

echo "Creating systemd service..."
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=${TOMCAT_USER}
Group=${TOMCAT_USER}

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
Environment="CATALINA_HOME=${INSTALL_DIR}"
Environment="CATALINA_BASE=${INSTALL_DIR}"
Environment="CATALINA_PID=${INSTALL_DIR}/temp/tomcat.pid"

ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh

Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting Tomcat..."
sudo systemctl enable tomcat
sudo systemctl start tomcat

echo "Opening firewall port 8081..."
sudo firewall-cmd --permanent --add-port=8081/tcp || true
sudo firewall-cmd --reload || true

echo "Tomcat installation completed!"
echo "Access Tomcat at: http://<your-server-ip>:8081"
