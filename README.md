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

curl -O https://raw.githubusercontent.com/hamedjafari/outline-user-migration/main/outline_migration.sh
chmod +x outline_migration.sh
sudo ./outline_migration.sh


## Quick Start (1-liner)

You can run the migration script directly with:

```bash
curl -s https://raw.githubusercontent.com/hamedjafari/outline-user-migration/main/outline_migration.sh | sudo bash
