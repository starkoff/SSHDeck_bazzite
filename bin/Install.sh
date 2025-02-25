#!/bin/bash

# Определение домашней директории целевого пользователя
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo ~$SUDO_USER)
else
    USER_HOME=$HOME
fi

# Revert to the backup, remove user (раскомментируйте при необходимости)
#\cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
#userdel -r sdcard
#groupdel sdcard

# Backup файла sshd_config, если бэкап не существует
FILE="/etc/ssh/sshd_config.backup"
if [ ! -f "$FILE" ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    echo "Created backup of sshd_config."
else
    echo "sshd_config is already backed up."
fi

# Создание группы sdcard
if grep -q -E "^sdcard:" /etc/group; then
    echo "sdcard group already exists."
else
    groupadd sdcard
    chgrp -R sdcard /run/media
    echo "Created sdcard group."
fi

# Создание пользователя sdcard
if id "sdcard" &>/dev/null; then
    echo 'User "sdcard" already exists.'
else
    useradd --home-dir /run/media/ --shell /bin/bash -g sdcard sdcard
    passwd -d sdcard
    echo 'Created sdcard user.'
fi

# Настройка chroot jail
if grep -Fxq "Match user sdcard" /etc/ssh/sshd_config; then
    echo 'sshd_config already contains chroot jail settings.'
else
    # Комментируем старую директиву Subsystem
    sed -i 's/Subsystem\tsftp\s\/usr\/lib\/ssh\/sftp-server/#Subsystem\tsftp\t\/usr\/lib\/ssh\/sftp-server/g' /etc/ssh/sshd_config

    # Добавляем новые настройки
    echo -e "\n# SSHDeck_bazzite configuration" >> /etc/ssh/sshd_config
    echo 'Subsystem	sftp	internal-sftp' >> /etc/ssh/sshd_config
    echo '' >> /etc/ssh/sshd_config
    echo 'Match user sdcard' >> /etc/ssh/sshd_config
    echo '	ChrootDirectory /run/media' >> /etc/ssh/sshd_config
    echo '	X11Forwarding no' >> /etc/ssh/sshd_config
    echo '	AllowTcpForwarding no' >> /etc/ssh/sshd_config
    echo '	PermitTunnel no' >> /etc/ssh/sshd_config
    echo '	AllowAgentForwarding no' >> /etc/ssh/sshd_config
    echo '	ForceCommand internal-sftp' >> /etc/ssh/sshd_config
    echo '	PasswordAuthentication yes' >> /etc/ssh/sshd_config
    echo '	PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
    echo 'Added chroot jail configuration to sshd_config.'
fi

# Создание директорий и загрузка файлов
echo "Creating directories in ${USER_HOME}..."
mkdir -p "${USER_HOME}/SSHToggle"
mkdir -p "${USER_HOME}/Desktop"

# Загрузка ToggleSSH.sh
echo "Downloading ToggleSSH.sh..."
curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.sh -o "${USER_HOME}/SSHToggle/ToggleSSH.sh"
chmod +x "${USER_HOME}/SSHToggle/ToggleSSH.sh"

# Загрузка иконки на рабочий стол
echo "Downloading Desktop shortcut..."
curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/ToggleSSH.desktop -o "${USER_HOME}/Desktop/ToggleSSH.desktop"
chmod +x "${USER_HOME}/Desktop/ToggleSSH.desktop"

# Финальные инструкции
echo -e "\nInstallation complete!"
echo "ToggleSSH.sh saved to: ${USER_HOME}/SSHToggle/"
echo "Desktop shortcut saved to: ${USER_HOME}/Desktop/"
echo -e "\nRestart SSH service when ready:"
echo "sudo systemctl restart sshd"
