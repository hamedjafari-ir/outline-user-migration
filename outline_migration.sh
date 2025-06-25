#!/bin/bash

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

apt update && apt upgrade -y

function transfer_outline() {
  read -p "Enter OLD server IP address: " OLD_IP
  read -p "Enter username for OLD server [default: root]: " USER
  USER=${USER:-root}
  read -s -p "Enter password for $USER@$OLD_IP: " PASSWORD
  echo ""

  # Check if sshpass is installed
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "Installing sshpass..."
    apt install sshpass -y
  fi

  # Check if /opt/outline exists on the old server
  echo "Checking /opt/outline on old server..."
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$OLD_IP" "test -d /opt/outline"
  if [[ $? -ne 0 ]]; then
    echo "No backup found on old server (/opt/outline not present)."
    return
  fi

  echo "Transferring Outline data..."
  sshpass -p "$PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" "$USER@$OLD_IP:/opt/outline/" /opt/outline/

  if [[ $? -eq 0 ]]; then
    echo "Transfer complete. Installing Outline on new server..."
    yes | sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-apps/master/server_manager/install_scripts/install_server.sh)"
    echo "Outline installation finished."
  else
    echo "Transfer failed."
  fi
}

function ping_ip() {
  read -p "Enter IP address to ping: " IP
  echo "Pinging $IP..."
  ping -c 10 "$IP"
}

# Main menu
while true; do
  echo "-----------------------------------------"
  echo " Outline Server Migration Utility"
  echo "-----------------------------------------"
  echo "1) Transfer Outline users from old server"
  echo "2) Ping a remote IP"
  echo "3) Exit"
  echo "-----------------------------------------"
  read -p "Choose an option [1-3]: " CHOICE

  case $CHOICE in
    1) transfer_outline ;;
    2) ping_ip ;;
    3) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
done
