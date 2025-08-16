#!/usr/bin/env bash

# Colors for output
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
RD=$(echo "\033[01;31m")
CL=$(echo "\033[m")
CM="${GN}✔️${CL}"
CROSS="${RD}✖️${CL}"
INFO="${YW}➤${CL}"

# Auto-detect default values
HOST_IP=$(hostname -I | awk '{print $1}')
DEFAULT_CTID=100
DEFAULT_NAME="filebrowser"
DEFAULT_CORES=1
DEFAULT_RAM=512
DEFAULT_DISK=4
DEFAULT_BRIDGE="vmbr0"
DEFAULT_IP="${HOST_IP}/24"
DEFAULT_GW="$(ip route | awk '/default/ {print $3}')"

# Prompt user with defaults
read -p "Enter Container ID (default: $DEFAULT_CTID): " CTID
CTID=${CTID:-$DEFAULT_CTID}

read -p "Enter Container Name (default: $DEFAULT_NAME): " CTNAME
CTNAME=${CTNAME:-$DEFAULT_NAME}

read -p "Enter CPU Cores (default: $DEFAULT_CORES): " CORES
CORES=${CORES:-$DEFAULT_CORES}

read -p "Enter RAM in MB (default: $DEFAULT_RAM): " RAM
RAM=${RAM:-$DEFAULT_RAM}

read -p "Enter Disk Size in GB (default: $DEFAULT_DISK): " DISK
DISK=${DISK:-$DEFAULT_DISK}

read -p "Enter Network Bridge (default: $DEFAULT_BRIDGE): " BRIDGE
BRIDGE=${BRIDGE:-$DEFAULT_BRIDGE}

read -p "Enter Static IP (default: $DEFAULT_IP): " IP
IP=${IP:-$DEFAULT_IP}

read -p "Enter Gateway (default: $DEFAULT_GW): " GW
GW=${GW:-$DEFAULT_GW}

# Prompt for root password
while true; do
  read -s -p "Enter root password (min 5 chars): " PASSWORD
  echo
  read -s -p "Retype root password: " PASSWORD2
  echo
  [[ "$PASSWORD" != "$PASSWORD2" ]] && echo -e "${CROSS} Passwords do not match. Try again." && continue
  [[ ${#PASSWORD} -lt 5 ]] && echo -e "${CROSS} Password must be at least 5 characters. Try again." && continue
  break
done

echo -e "${INFO} Creating LXC container ${CTID}..."

pct create $CTID local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst \
  -hostname $CTNAME \
  -cores $CORES \
  -memory $RAM \
  -rootfs local-zfs:${DISK} \
  -net0 name=eth0,bridge=$BRIDGE,ip=$IP,gw=$GW \
  -unprivileged 1 \
  -features nesting=1 \
  -password "$PASSWORD" \
  -start 1

echo -e "${INFO} Waiting for container to start..."
sleep 5

echo -e "${INFO} Installing FileBrowser in container..."
pct exec $CTID -- bash -c "curl -fsSL https://raw.githubusercontent.com/Najdat/proxmox-filebrowser-lxc/main/filebrowser-install.sh | bash"

echo -e "${CM} FileBrowser LXC deployed and installation started."
