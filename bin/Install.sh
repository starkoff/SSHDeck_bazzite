#!/bin/bash

USER_HOME=$( [ -n "$SUDO_USER" ] && eval echo ~$SUDO_USER || echo $HOME )
CONFIG_DIR="$USER_HOME/SSHToggle"
PASSWORD_FILE="$CONFIG_DIR/.pass"

get_password() {
  mkdir -p "$CONFIG_DIR"
  if [ -f "$PASSWORD_FILE" ]; then
    PASSWORD=$(cat "$PASSWORD_FILE")
  else
    echo -n "Enter deck user password (press Enter for no password): "
    read -s PASSWORD
    echo
    echo "$PASSWORD" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    chown $(id -u):$(id -g) "$PASSWORD_FILE"
  fi
}

configure_sshd() {
  local sftp_path=$({
    [ -x "/usr/lib/ssh/sftp-server" ] && echo "/usr/lib/ssh/sftp-server" ||
    [ -x "/usr/libexec/openssh/sftp-server" ] && echo "/usr/libexec/openssh/sftp-server"
  } | head -1)

  sudo sed -i "s|Subsystem[[:space:]]*sftp[[:space:]]*$sftp_path|#&|g" /etc/ssh/sshd_config
  grep -q "Subsystem.sftp.internal-sftp" /etc/ssh/sshd_config || \
    echo "Subsystem sftp internal-sftp" | sudo tee -a /etc/ssh/sshd_config >/dev/null

  if ! grep -q "Match User sdcard" /etc/ssh/sshd_config; then
    sudo tee -a /etc/ssh/sshd_config >/dev/null <<EOF

# SSHDeck Configuration
Match User sdcard
    ChrootDirectory /run/media
    ForceCommand internal-sftp
    PasswordAuthentication yes
    PermitEmptyPasswords yes
    X11Forwarding no
    AllowTcpForwarding no
    PermitTunnel no
    AllowAgentForwarding no
EOF
  fi
}

main() {
  # Backup SSH config
  sudo cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

  # Create sdcard group
  sudo getent group sdcard >/dev/null || {
    sudo groupadd sdcard
    sudo chgrp sdcard /run/media
  }

  # Create sdcard user
  sudo id sdcard &>/dev/null || {
    sudo useradd --home-dir /run/media --shell /bin/bash -g sdcard sdcard
    sudo passwd -d sdcard
  }

  # Configure permissions
  sudo chmod 755 /run/media
  id deck &>/dev/null && sudo usermod -aG sdcard deck

  # Get password and configure SSH
  get_password
  configure_sshd

  # Install control script
  sudo curl -sL https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.sh \
    -o "$CONFIG_DIR/ToggleSSH.sh"
  sudo chmod +x "$CONFIG_DIR/ToggleSSH.sh"

  # Install desktop icon
  sudo curl -sL https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.desktop \
    | sed "s|TOGGLE_SCRIPT_PATH|$CONFIG_DIR/ToggleSSH.sh|g" \
    > "$USER_HOME/Desktop/ToggleSSH.desktop"
  sudo chmod +x "$USER_HOME/Desktop/ToggleSSH.desktop"

  sudo systemctl restart sshd
  echo -e "\nInstallation complete! Control icon: $USER_HOME/Desktop/ToggleSSH.desktop"
}

main
