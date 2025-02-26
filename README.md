# SSH Server для Steam Deck: Полное руководство

**Безопасный временный доступ | Поддержка SteamOS, Bazzite и других модификаций**

## 🔍 Ключевые особенности
- Однокомандная установка
- Автовыключение SSH при закрытии окна
- Полная совместимость с Bazzite/SteamOS
- Изоляция доступа к SD-карте

## 🛠 Установка за 2 шага
1. Выполните в терминале:
```bash
sudo bash -c "$(curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/Install.sh)"
```
2. Найдите иконку **Toggle SSH** на рабочем столе

## 🔐 Безопасность и совместимость
### ✔️ Поддерживаемые системы
- Официальная SteamOS (все версии)
- Bazzite/Bluefin/Serpent OS
- Arch Linux и производные

### ⚠️ Меры защиты
- Chroot-тюрьма для пользователя `sdcard`
- SSH-сессия длится только пока открыто окно
- Автоматический бэкап конфигов

## 📁 Использование с WinSCP/FileZilla
```ini
Хост: [Локальный IP Deck]
Порт: 22
Пользователь: sdcard
Пароль: (оставить пустым)
Протокол: SFTP
```

## ⚙️ Дополнительные настройки
### Парольная аутентификация
1. Откройте файл с паролем:
```bash
nano ~/SSHToggle/.pass
```
2. Введите новый пароль (первая строка файла)
3. Сохраните изменения (Ctrl+O → Enter → Ctrl+X)

### Смена порта SSH
1. Отредактируйте конфиг:
```bash
sudo nano /etc/ssh/sshd_config
```
2. Перезапустите сервис:
```bash
sudo systemctl restart sshd
```

## 🗑️ Полное удаление
```bash
sudo bash ~/SSHToggle/ToggleSSH.sh --remove
```
*Удалит: пользователя, группу, файлы конфигурации*

## 📂 Структура проекта
```
bin/
├── Install.sh          # Основной установщик
├── ToggleSSH.sh        # Управление SSH (вкл/выкл)
└── ToggleSSH.desktop   # Иконка запуска
```

## ❓ Частые вопросы
**Q: Как проверить статус SSH?**
```bash
systemctl status sshd
```

**Q: Как сбросить пароль?**
```bash
echo "ваш_новый_пароль" > ~/SSHToggle/.pass && chmod 600 ~/SSHToggle/.pass
```

**Q: Работает ли на Bazzite?**
✅ Да, протестировано на Bazzite GNOME/KDE

**Q: Как найти IP адрес?**
```bash
ip -brief address show
```

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Bazzite Compatible](https://img.shields.io/badge/Bazzite-Supported-success)](https://github.com/ublue-os/bazzite)
[![SteamOS Verified](https://img.shields.io/badge/Steam_Deck-Supported-blue)](https://store.steampowered.com/steamos)

- 
- 
- 
-------------- 
# Steam Deck SSH Server: Secure Setup Guide for Bazzite and SteamOS

**Temporary SSH Access with Auto-Disabling Feature  **

## 🔍 Top Search Keywords
- How to setup SSH on Steam Deck
- Steam Deck Bazzite SSH configuration
- Secure SFTP access Steam Deck
- Auto-disable SSH server SteamOS

## ✔️ Compatibility Highlights
- Official SteamOS (all versions)
- Bazzite/Bluefin/Serpent OS
- Arch Linux and derivatives

## 🚀 30-Second Installation
```bash
sudo bash -c "$(curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/Install.sh)"
```

**What Gets Installed:**
1. Restricted `sdcard` user (passwordless)
2. Chroot jail limited to `/run/media`
3. Desktop toggle script and icon

## 🔐 Security Architecture
### Core Protections
- SSH session dies with popup window
- User confinement via chroot
- Automatic config backup
- No root privileges

## 📂 Usage with Clients
**Supported Clients:**
- WinSCP (Windows)
- FileZilla (Cross-Platform)
- Cyberduck (Mac)

**Connection Template:**
```ini
Host = [Deck's Local IP]
User = sdcard
Port = 22
Protocol = SFTP
```

## ⚙️ Advanced Configuration
### Password Authentication
1. Open the password file:
```bash
nano ~/SSHToggle/.pass
```
2. Enter a new password (first line of the file)
3. Save changes (Ctrl+O → Enter → Ctrl+X)

### Port Modification
1. Edit config:
```bash
sudo nano /etc/ssh/sshd_config
```
2. Restart service:
```bash
sudo systemctl restart sshd
```

## 🗑️ Complete Uninstallation
```bash
sudo bash ~/SSHToggle/ToggleSSH.sh --remove
```
*Removes: sdcard user, config changes, all files*

## 📜 Technical Breakdown
### File Structure
```
bin/
├── Install.sh          # Main installer
├── ToggleSSH.sh        # Toggle script
└── ToggleSSH.desktop   # Launcher icon
```

### Bazzite-Specific Features
- Automatic path detection
- Systemd service integration
- Post-update survival

## ❓ FAQ (Featured Snippet Targets)
**Q: How to check SSH status?**
```bash
systemctl status sshd
```

**Q: Works on Bazzite KDE?**
✅ Yes, tested on Bazzite 4.1+

**Q: Find Steam Deck IP?**
```bash
ip -brief address show
```
---
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Bazzite Compatible](https://img.shields.io/badge/Bazzite-Supported-success)](https://github.com/ublue-os/bazzite)
[![SteamOS Verified](https://img.shields.io/badge/Steam_Deck-Supported-blue)](https://store.steampowered.com/steamos)
