#!/usr/bin/env bash

# Update and install dependencies
apt-get update
apt-get install -y curl wget tar

# Download and install FileBrowser
curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar -xz -C /usr/local/bin
chmod +x /usr/local/bin/filebrowser

# Create FileBrowser configuration directory
mkdir -p /etc/filebrowser

# Prompt for authentication method
read -p "Use No Authentication? (y/n): " NOAUTH

if [[ "$NOAUTH" == "y" || "$NOAUTH" == "Y" ]]; then
  /usr/local/bin/filebrowser config init --auth.method=noauth
else
  read -p "Enter admin username: " ADMIN_USER
  read -p "Enter admin password: " ADMIN_PASS
  /usr/local/bin/filebrowser config init
  /usr/local/bin/filebrowser users add $ADMIN_USER $ADMIN_PASS --perm.admin
fi

# Create systemd service
cat <<EOF >/etc/systemd/system/filebrowser.service
[Unit]
Description=FileBrowser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -r /
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start FileBrowser service
systemctl enable filebrowser
systemctl start filebrowser

echo "FileBrowser installation complete. Access it via http://<container-ip>:8080"
