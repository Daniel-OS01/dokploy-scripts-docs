#!/bin/bash
#
# Improved Server Initialization Script
#
# This script prepares an Ubuntu VPS for a Dokploy/Docker Swarm workload.
# It focuses on:
# 1. Safer SSH key and sudo configuration.
# 2. Correct firewall setup (UFW) that is compatible with Docker.
#
# USAGE: Run as root or with sudo.
#

# Exit immediately if a command fails, treat unset variables as an error,
# and ensure pipeline failures are detected.
set -euo pipefail

# Ensure script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo." >&2
   exit 1
fi

echo "--- [1/4] Configuring User Access ---"

# --- SSH Key for Root ---
echo "Configuring root SSH access..."
if [ -f "/home/ubuntu/.ssh/authorized_keys" ]; then
    mkdir -p /root/.ssh
    cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    chown -R root:root /root/.ssh
    echo "Successfully copied 'ubuntu' user's authorized_keys to root."
else
    echo "WARNING: /home/ubuntu/.ssh/authorized_keys not found. Root SSH key login will not be set up from this file."
fi

# --- Sudoers Configuration ---
echo "Configuring passwordless sudo for 'ubuntu' user..."
# Using /etc/sudoers.d/ is the standard, safe, and idempotent method.
# Appending to /etc/sudoers directly (as in the original) is dangerous
# and will create duplicate entries if run multiple times.
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-ubuntu-nopasswd
chmod 440 /etc/sudoers.d/90-ubuntu-nopasswd
echo "Sudo configuration applied."

echo
echo "--- [2/4] Configuring OpenSSH Server ---"

# Update package lists and ensure SSH server is installed
apt-get update
apt-get install -y openssh-server

# --- SSH Security Configuration ---
# WARNING: The original script set 'PermitRootLogin yes'. This is a
# significant security risk as it allows root login via any method,
# including passwords if 'PasswordAuthentication' is also 'yes'.
#
# A much safer alternative is 'PermitRootLogin prohibit-password',
# which only allows key-based root login.
#
# This script will implement the *safer* 'prohibit-password' option.
echo "Securing SSH: Setting 'PermitRootLogin prohibit-password' (key-only)..."
if grep -q "^#*PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config
fi

# Also disable password authentication entirely for better security
echo "Securing SSH: Setting 'PasswordAuthentication no'..."
if grep -q "^#*PasswordAuthentication" /etc/ssh/sshd_config; then
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
else
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi

systemctl restart sshd
echo "SSHD configured securely and restarted."

echo
echo "--- [3/4] Configuring Firewall (UFW) for Docker ---"

# Ensure UFW is installed
apt-get install -y ufw

# --- Docker & UFW Compatibility Fix ---
# This is the standard method to allow Docker to manage its own networking
# without UFW's FORWARD policy interfering. This change makes the
# manual 'iptables -D FORWARD...' rules from the original script unnecessary.
echo "Setting UFW DEFAULT_FORWARD_POLICY to ACCEPT for Docker compatibility..."
if grep -q "^#*DEFAULT_FORWARD_POLICY" /etc/default/ufw; then
     sed -i 's/^#*DEFAULT_FORWARD_POLICY.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
else
    echo 'DEFAULT_FORWARD_POLICY="ACCEPT"' >> /etc/default/ufw
fi

# --- UFW Rules ---
# The original script mixed ufw and iptables rules for the same ports.
# This is unnecessary as UFW manages iptables. We only use UFW here.
echo "Adding UFW rules for SSH, Dokploy, and Docker Swarm..."

# Always allow SSH first!
ufw allow 22/tcp comment 'SSH'

# Dokploy Ports
ufw allow 80/tcp   comment 'HTTP'
ufw allow 443/tcp  comment 'HTTPS'
ufw allow 3000/tcp comment 'Dokploy UI'
ufw allow 996/tcp  comment 'Dokploy Agent'

# Docker Swarm Ports
ufw allow 2377/tcp comment 'Swarm cluster management'
ufw allow 7946/tcp comment 'Swarm node communication'
ufw allow 7946/udp comment 'Swarm node communication'
ufw allow 4789/udp comment 'Swarm overlay network'

# Enable and reload UFW
echo "Enabling and reloading UFW..."
ufw --force enable
ufw reload
echo "UFW enabled and reloaded."

echo
echo "--- [4/4] Final Status ---"
ufw status verbose

echo
echo "Server initialization complete."
