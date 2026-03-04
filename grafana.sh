#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Production-ready Grafana Enterprise installation script
# Supports: Debian / Ubuntu
# ------------------------------------------------------------------------------

set -Eeuo pipefail

# ---- VARIABLES ----
GRAFANA_KEYRING="/etc/apt/keyrings/grafana.asc"
GRAFANA_REPO_FILE="/etc/apt/sources.list.d/grafana.list"
GRAFANA_REPO_LINE="deb [signed-by=${GRAFANA_KEYRING}] https://apt.grafana.com stable main"
GRAFANA_GPG_URL="https://apt.grafana.com/gpg-full.key"

# ---- LOGGING ----
log() {
  echo "[INFO] $1"
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

# ---- ROOT CHECK ----
if [[ "$EUID" -ne 0 ]]; then
  error "This script must be run as root. Use sudo."
fi

export DEBIAN_FRONTEND=noninteractive

log "Installing required dependencies..."
apt-get update -y
apt-get install -y apt-transport-https wget gnupg

log "Creating keyring directory..."
install -d -m 0755 /etc/apt/keyrings

log "Downloading Grafana GPG key..."
wget -q -O "${GRAFANA_KEYRING}" "${GRAFANA_GPG_URL}"
chmod 0644 "${GRAFANA_KEYRING}"

log "Configuring Grafana APT repository..."
if [[ ! -f "${GRAFANA_REPO_FILE}" ]] || ! grep -Fxq "${GRAFANA_REPO_LINE}" "${GRAFANA_REPO_FILE}"; then
  echo "${GRAFANA_REPO_LINE}" > "${GRAFANA_REPO_FILE}"
  log "Repository added."
else
  log "Repository already configured."
fi

log "Updating package list..."
apt-get update -y

log "Installing Grafana Enterprise..."
apt-get install -y grafana-enterprise

log "Reloading systemd daemon..."
systemctl daemon-reload

log "Enabling Grafana service..."
systemctl enable grafana-server

log "Starting Grafana service..."
systemctl restart grafana-server

log "Verifying service status..."
if systemctl is-active --quiet grafana-server; then
  log "Grafana Enterprise is running successfully."
else
  error "Grafana service failed to start."
fi

log "Installation completed successfully."
log "Access Grafana at: http://<server-ip>:3000"
