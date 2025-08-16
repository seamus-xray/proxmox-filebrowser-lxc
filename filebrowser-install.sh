#!/usr/bin/env bash

# Auto-install FileBrowser in Proxmox LXC with default prompts and improved UX
# Author: Najdat (Customized from community-scripts by tteck)

set -e

# Function to prompt with default
prompt() {
  local prompt_text="$1"
  local default_value="$2"
  read -p "$prompt_text (Default: $default_value): " value
  echo "${value:-$default_value}"
}

# Detect host IP
HOST_IP=$(hostname -I | awk '{print $1}')
SUGGESTED_IP="${HOST_IP%.*}.122"
GATEWAY="${HOST_IP%.*}.1"

# Ask for user input with defaults
read -p "Enter Container ID (e.g., 100): " CTID
if [[ -z "$CTID" ]]; then echo "Container ID is required"; exit 1; fi

HOSTNAME=$(prompt "Enter Container Name" "filebrowser")
CORES=$(prompt "Enter CPU Cores" "1")
MEMORY=$(prompt "Enter RAM in MB" "512")
DISK=$(prompt "Enter Disk Size in GB" "5")
BRIDGE=$(prompt "Enter Network Bridge" "vmbr0")
IP=$(prompt "Enter Static IP" "$SUGGESTED_IP/24")
GATEWAY=$(prompt "Enter Gateway" "$GATEWAY")

# Password prompt with check
while true; do
  read -s -p "Enter new password (min 5 chars): " PASSWORD
  echo
  read -s -p "Retype new password: " PASSWORD_CONFIRM
  echo
  if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "Passwords do not match. Try again."
  elif [[ ${#PASSWORD} -lt 5 ]]; then
    echo "Password must be at least 5 characters."
  else
    break
  fi
done

# Create the LXC container
TEMPLATE="local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
pct create $CTID $TEMPLATE \
  -hostname $HOSTNAME \
  -cores $CORES \
  -memory $MEMORY \
  -rootfs local-zfs:${DISK} \
  -net0 name=eth0,bridge=$BRIDGE,ip=$IP,gw=$GATEWAY \
  -unprivileged 1 \
  -features nesting=1 \
  -password $PASSWORD \
  -start 1

# Wait and execute the FileBrowser setup script
sleep 5
pct exec $CTID -- bash -c "bash <(curl -fsSL https://raw.githubusercontent.com/Najdat/proxmox-filebrowser-lxc/main/filebrowser-setup.sh)"

echo "\n✅ LXC Container $CTID ($HOSTNAME) with FileBrowser has been created and configured."
