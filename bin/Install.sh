#!/bin/bash

# Определение домашней директории
USER_HOME=$( [ -n "$SUDO_USER" ] && eval echo ~$SUDO_USER || echo $HOME )

# SFTP path detection для мультидистрибутивности
SFTP_PATH=$(which sftp-server 2>/dev/null || {
  [ -f "/usr/lib/ssh/sftp-server" ] && echo "/usr/lib/ssh/sftp-server" || echo "/usr/libexec/openssh/sftp-server"
})

# Backup sshd_config
if [ ! -f /etc/ssh/sshd_config.backup ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    echo "Created backup of sshd_config."
else
    echo "sshd_config backup already exists."
fi

# Настройка группы и пользователя
if ! grep -q -E "^sdcard:" /etc/group; then
    groupadd sdcard
    chgrp -R sdcard /run/media
    echo "Created sdcard group."
    [[ $(getent group sdcard) ]] || { echo "Group creation failed!"; exit 1; }
fi

if ! id "sdcard" &>/dev/null; then
    useradd --home-dir /run/media/ --shell /bin/bash -g sdcard sdcard
    passwd -d sdcard
    [[ $(id sdcard) ]] || { echo "User creation failed!"; exit 1; }
fi

# Chroot jail configuration
if ! grep -Fxq "Match User sdcard" /etc/ssh/sshd_config; then
    sed -i "s|Subsystem[[:space:]]*sftp[[:space:]]*$SFTP_PATH|#&\nSubsystem\tsftp\tinternal-sftp|g" /etc/ssh/sshd_config

    echo -e "\n# SSHDeck configuration" >> /etc/ssh/sshd_config
    cat <<EOF >> /etc/ssh/sshd_config
Match User sdcard
    ChrootDirectory /run/media
    X11Forwarding no
    AllowTcpForwarding no
    PermitTunnel no
    AllowAgentForwarding no
    ForceCommand internal-sftp
    PasswordAuthentication yes
    PermitEmptyPasswords yes
EOF

    # SELinux context для Bazzite
    if command -v semanage &>/dev/null; then
        if ! semanage fcontext -a -t ssh_home_t "/run/media(/.*)?" 2>/dev/null; then
            echo "SELinux: Failed to add context, trying restorecon..."
            restorecon -Rv /run/media
        fi
    fi

    echo "Added chroot jail configuration."
fi

# Делегирование прав для Steam Deck
if [ -d "/home/deck" ]; then
    usermod -aG sdcard deck
    chmod 770 /run/media
fi

# File deployment
mkdir -p ${USER_HOME}/SSHToggle ${USER_HOME}/Desktop
curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.sh -o ${USER_HOME}/SSHToggle/ToggleSSH.sh
chmod +x ${USER_HOME}/SSHToggle/ToggleSSH.sh

curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.desktop | \
    sed "s|TOGGLE_SCRIPT_PATH|${USER_HOME}/SSHToggle/ToggleSSH.sh|g" > \
    ${USER_HOME}/Desktop/ToggleSSH.desktop
chmod +x ${USER_HOME}/Desktop/ToggleSSH.desktop

# Final checks
if ! systemctl is-active sshd &>/dev/null; then
    systemctl start sshd
    systemctl enable sshd
fi

echo -e "\nInstallation success! Reboot or run: sudo systemctl restart sshd"
