# Proxmox FileBrowser LXC

This project provides an automated script to deploy [FileBrowser](https://filebrowser.org/) in a lightweight, dedicated LXC container on your Proxmox VE host.

> No manual configuration required  
> Automatically installs FileBrowser  
> Supports user-defined container specs (CPU, RAM, disk)  
> Choice of authentication mode (NoAuth or admin login)

---

## Features

- Deploys a minimal Debian-based LXC container
- Installs FileBrowser with systemd service
- Optional: No Authentication or default admin login
- Auto-detects host IP and port
- Clean uninstall/update logic

---

## Quick Deployment

To deploy the container directly from your Proxmox shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Najdat/proxmox-filebrowser-lxc/main/filebrowser-lxc.sh)"
