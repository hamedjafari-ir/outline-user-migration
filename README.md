# Outline Migration Tool

This is a Bash-based utility to help you **migrate Outline VPN users** from an old server to a new one. It transfers the Outline configuration directory (`/opt/outline`) securely over SSH and installs a fresh Outline server with Docker.

## Features

- ✅ Update and upgrade the new server automatically  
- 🔐 Connect to the old server via SSH using password authentication  
- 📂 Transfer the Outline configuration folder (`/opt/outline`)  
- 🐳 Automatically install Docker and Outline server  
- 📶 Includes ping test to check remote server availability  

## Requirements

- Ubuntu server (tested on Ubuntu 20.04 and 22.04)  
- `rsync`, `sshpass`, `wget`, `curl`  
- Run as root (`sudo ./outline_migration.sh`)  

## Usage

```bash
curl -O https://raw.githubusercontent.com/hamedjafari-ir/outline-user-migration/main/outline_migration.sh
chmod +x outline_migration.sh
sudo ./outline_migration.sh

Quick Start (1-liner)

You can run the migration script directly with:

curl -O https://raw.githubusercontent.com/hamedjafari-ir/outline-user-migration/main/outline_migration.sh && chmod +x outline_migration.sh && sudo ./outline_migration.sh

⚠️ Note for AWS / EC2 Users

If you're using cloud services like AWS EC2, password-based SSH login is disabled by default, and connections are allowed only via SSH key authentication.

To enable password login (required for this migration script to work via sshpass), you can run the script below. It will ask you to create a username and password, and then automatically update your SSH configuration to allow password-based authentication:

curl -O https://raw.githubusercontent.com/hamedjafari-ir/outline-user-migration/main/enable_password_ssh_access.sh && chmod +x enable_password_ssh_access.sh && sudo ./enable_password_ssh_access.sh

After running this script, you'll be able to connect to the EC2 server using a password — and then run the Outline migration script without needing an SSH key.
