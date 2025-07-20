#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_CONFIG="/etc/ssh/sshd_config.migration.backup"

function pause() {
  read -p "Press Enter to continue..."
}

function create_user() {
  echo ""
  read -p "Enter username to create [default: rootmigration]: " USERNAME
  USERNAME=${USERNAME:-rootmigration}

  echo "Enter password for '$USERNAME':"
  read -s PASSWORD

  # Create user if not exists
  if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists."
  else
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
    echo "✅ User '$USERNAME' created and added to sudo group."
  fi

  # Backup SSH config
  if [[ ! -f "$BACKUP_CONFIG" ]]; then
    cp "$SSHD_CONFIG" "$BACKUP_CONFIG"
    echo "📦 SSH config backed up to $BACKUP_CONFIG"
  fi

  echo "🔧 Updating SSH configuration..."

  # Ensure password login enabled
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONFIG"
  sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
  sed -i 's/^#\?UsePAM .*/UsePAM yes/' "$SSHD_CONFIG"
  sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"

  # Remove any restrictive Match blocks
  if grep -q "^Match" "$SSHD_CONFIG"; then
    echo "⚠️ Removing Match blocks in sshd_config (if any)..."
    awk '/^Match/{exit} {print}' "$SSHD_CONFIG" > /tmp/sshd_config.clean && mv /tmp/sshd_config.clean "$SSHD_CONFIG"
  fi

  systemctl restart sshd
  echo ""
  echo "✅ SSH password login is now enabled."
  echo "You can now log in with: ssh $USERNAME@<your-server-ip>"
  pause
}

function ping_ip() {
  read -p "Enter IP address to ping: " IP
  ping -c 5 "$IP"
  pause
}

function remove_user() {
  read -p "Enter username to remove [default: rootmigration]: " USERNAME
  USERNAME=${USERNAME:-rootmigration}

  read -p "Are you sure you want to remove user '$USERNAME' and restore SSH config? (y/N): " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "❌ Cancelled."
    pause
    return
  fi

  if id "$USERNAME" &>/dev/null; then
    pkill -u "$USERNAME"
    userdel -r "$USERNAME"
    echo "🗑️ User '$USERNAME' deleted."
  else
    echo "User '$USERNAME' not found."
  fi

  if [[ -f "$BACKUP_CONFIG" ]]; then
    cp "$BACKUP_CONFIG" "$SSHD_CONFIG"
    systemctl restart sshd
    echo "🔁 SSH config restored from backup."
  else
    echo "⚠️ No SSH config backup found."
  fi

  pause
}

# Menu
while true; do
  clear
  echo "----------------------------------------------"
  echo " EC2 Password SSH Access & User Setup Script"
  echo "----------------------------------------------"
  echo "1) Create user & enable password SSH access"
  echo "2) Ping a remote IP"
  echo "3) Remove user and restore SSH config"
  echo "4) Exit"
  echo "----------------------------------------------"
  read -p "Choose an option [1-4]: " CHOICE

  case $CHOICE in
    1) create_user ;;
    2) ping_ip ;;
    3) remove_user ;;
    4) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option."; pause ;;
  esac
done
