#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

USERNAME="rootmigration"
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_CONFIG="/etc/ssh/sshd_config.backup.migration"

function pause() {
  read -p "Press Enter to continue..."
}

function create_user() {
  echo "Enter password for new user '$USERNAME':"
  read -s PASSWORD

  if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
  else
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
    echo "User $USERNAME created and added to sudo group."
  fi

  if [[ ! -f "$BACKUP_CONFIG" ]]; then
    cp "$SSHD_CONFIG" "$BACKUP_CONFIG"
    echo "Original SSH config backed up."
  fi

  echo "Configuring SSH to allow password login..."

  # Safely enable password login
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONFIG"
  sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"
  sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
  sed -i 's/^#\?UsePAM .*/UsePAM yes/' "$SSHD_CONFIG"

  systemctl restart sshd
  echo "✅ SSH password login is now enabled. You can now connect using:"
  echo "ssh $USERNAME@<your-ec2-ip>"
  pause
}

function ping_ip() {
  read -p "Enter IP address to ping: " IP
  ping -c 5 "$IP"
  pause
}

function remove_user() {
  read -p "Are you sure you want to remove $USERNAME and restore SSH config? (y/N): " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    pause
    return
  fi

  if id "$USERNAME" &>/dev/null; then
    pkill -u "$USERNAME"
    userdel -r "$USERNAME"
    echo "User $USERNAME deleted."
  else
    echo "User $USERNAME does not exist."
  fi

  if [[ -f "$BACKUP_CONFIG" ]]; then
    cp "$BACKUP_CONFIG" "$SSHD_CONFIG"
    systemctl restart sshd
    echo "✅ SSH config restored to original state."
  else
    echo "No backup SSH config found. Manual revert may be required."
  fi

  pause
}

# Main menu
while true; do
  clear
  echo "------------------------------------------"
  echo " EC2 Root Access & SSH Config Tool"
  echo "------------------------------------------"
  echo "1) Create root-like user with password login"
  echo "2) Ping a remote IP"
  echo "3) Remove user and restore SSH config"
  echo "4) Exit"
  echo "------------------------------------------"
  read -p "Choose an option [1-4]: " CHOICE

  case $CHOICE in
    1) create_user ;;
    2) ping_ip ;;
    3) remove_user ;;
    4) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option."; pause ;;
  esac
done
