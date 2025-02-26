#!/bin/bash

# Укажите корректный UUID вашего диска или оставьте пустым для автоматического вывода доступных дисков
UUID=""

MOUNT_POINT="/var/mnt/gamedisk"

# Проверяем, что система является SteamOS или Bazzite
if grep -iq "SteamOS" /etc/os-release; then
    OS="SteamOS"
elif grep -iq "Bazzite" /etc/os-release; then
    OS="Bazzite"
else
    echo "Этот скрипт предназначен только для SteamOS и Bazzite."
    exit 1
fi

# Если UUID не указан, показываем список доступных дисков
if [ -z "$UUID" ]; then
    #DISK_LIST=$(lsblk -o NAME,UUID,FSTYPE,SIZE,MOUNTPOINT | grep -v "loop")
     lsblk -o NAME,UUID,FSTYPE,SIZE,MOUNTPOINT | grep -v "loop"   
    #zenity --info --text="Вы не указали UUID. Вот список доступных дисков:\n\n$DISK_LIST\n\nПожалуйста, укажите UUID вручную в скрипте перед его запуском." --title="Список доступных дисков"
    
    exit 1
fi

# Запрашиваем пароль sudo через графический интерфейс zenity
current_password=$(zenity --password --title "Требуется пароль sudo")
echo -e "$current_password\n" | sudo -S ls &> /dev/null
if [ $? -ne 0 ]; then
    zenity --error --text "Неверный пароль sudo!" --title "Ошибка аутентификации"
    exit 1
fi

# Проверяем, существует ли запись в /etc/fstab
if grep -qs "$MOUNT_POINT" /etc/fstab; then
    zenity --info --text "Запись для $MOUNT_POINT уже существует в /etc/fstab." --title "Информация"
    exit 0
fi

# Создаем папку монтирования, если она не существует
if [ ! -d "$MOUNT_POINT" ]; then
    echo "$current_password" | sudo -S mkdir -p "$MOUNT_POINT"
fi

# Формируем запись для fstab
FSTAB_ENTRY="UUID=$UUID    $MOUNT_POINT    ext4    defaults    0    2"

# Показываем пользователю, какую запись будем добавлять
zenity --info --text "Добавляем следующую запись в /etc/fstab:\n$FSTAB_ENTRY" --title "Добавление записи"

# Создаем резервную копию /etc/fstab
echo "$current_password" | sudo -S cp /etc/fstab /etc/fstab.bak

# Добавляем запись в /etc/fstab
echo "$current_password" | sudo -S sh -c "echo \"$FSTAB_ENTRY\" >> /etc/fstab"

# Сообщаем об успешном завершении
zenity --info --text "Готово! Вы можете выполнить 'sudo mount -a' для применения изменений." --title "Успешно"
