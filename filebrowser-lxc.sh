#!/usr/bin/env bash

# Prompt for user input
read -p "Enter Container ID (e.g., 100): " CTID
read -p "Enter Container Name: " CTNAME
read -p "Enter CPU Cores (e.g., 1): " CPU
read -p "Enter RAM in MB (e.g., 1024): " RAM
read -p "Enter Disk Size in GB (e.g., 10): " DISK
read -p "Enter Network Bridge (e.g., vmbr0): " BRIDGE
read -p "Enter Static IP (e.g., 192.168.1.100/24): " IP
read -p "Enter Gateway (e.g., 192.168.1.1): " GW

# Create the container
pct create $CTID local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst \
  -hostname $CTNAME \
  -cores $CPU \
  -memory $RAM \
  -rootfs local-lvm:$DISK \
  -net0 name=eth0,bridge=$BRIDGE,ip=$IP,gw=$GW \
  -unprivileged 1 \
  -features nesting=1 \
  -password '' \
  -start 1

# Wait for the container to start
sleep 5

# Download and execute the installation script inside the container
pct exec $CTID -- bash -c "curl -fsSL https://raw.githubusercontent.com/yourusername/yourrepo/main/filebrowser-install.sh | bash"
