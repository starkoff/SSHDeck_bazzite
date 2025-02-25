# SSHDeck
**Safe SSH toggle solution for Steam Deck**

Установщик создает пользователя ""sdcard"" и временно включает SSH до закрытия окна. Решение позволяет использовать WinSCP для безопасного доступа к SD-карте.

## Установка
**Одной командой (рекомендуется):**
```bash
sudo bash -c ""$(curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/Install.sh)""
```

**Что произойдет:**
1. Создаст пользователя `sdcard` без пароля
2. Настроит chroot-окружение для доступа только к `/run/media`
3. Разместит:
   - Скрипт управления: `~/SSHToggle/ToggleSSH.sh`
   - Иконку запуска: `~/Desktop/ToggleSSH.desktop`

## Настройка пароля (опционально)
Если у пользователя `deck` установлен пароль:
1. Откройте файл:
```bash
nano ~/SSHToggle/ToggleSSH.sh
```
2. Измените строку:
```bash
PASSWORD=""DEFAULT_EMPTY_VALUE"" → PASSWORD=""your_deck_password""
```

## Использование
1. Запустите иконку **Toggle SSH** на рабочем столе
2. Используйте данные из окна для подключения
3. При закрытии окна - SSH автоматически отключается

## Параметры безопасности
- SSH работает только при активном окне
- Перезагрузка/сон устройства отключают доступ
- Пользователь `sdcard` ограничен только SD-картой

## Для разработчиков
**Структура проекта:**
```
bin/
├── Install.sh          # Основной установщик
├── ToggleSSH.sh        # Скрипт управления
└── ToggleSSH.desktop   # Шаблон иконки
```

**Особенности реализации:**
- Динамическое определение домашней директории
- Автоматический бэкап sshd_config
- Поддержка SteamOS и других Linux-дистрибутивов

## Удаление
```bash
sudo bash ~/SSHToggle/ToggleSSH.sh --remove
```





-------------- 


# SSHDeck
**Safe SSH Toggle Solution for Steam Deck & Linux**  
Temporary SSH access with chroot confinement for secure file transfers via [WinSCP](https://winscp.net/eng/index.php).

## Installation
### One-Command Install
```bash
sudo bash -c ""$(curl -L https://raw.githubusercontent.com/starkoff/SSHDeck_bazzite/main/bin/Install.sh)""
```

### What This Does:
1. 🔧 Creates restricted `sdcard` user (no password)
2. 🔒 Configures chroot jail to `/run/media`
3. 📦 Deploys:
   - Control script: `~/SSHToggle/ToggleSSH.sh`
   - Desktop launcher: `~/Desktop/ToggleSSH.desktop`

## Configuration
### Password Setup (Optional)
If your main user has a password:
1. Edit the script:
```bash
nano ~/SSHToggle/ToggleSSH.sh
```
2. Update line:
```diff
- PASSWORD=""DEFAULT_EMPTY_VALUE""
+ PASSWORD=""your_actual_password""
```

## Usage
1. Double-click **Toggle SSH** desktop icon
2. Use connection details from popup:
   ```ini
   Host = [Your Device IP]
   User = deck or sdcard
   Port = 22
   ```
3. ❌ Close popup to disable SSH immediately

## Security Features
- 🕒 SSH only active while window is open
- 🔄 Auto-disables on reboot/sleep
- 📁 Restricted to SD card directory
- 👤 Separate non-privileged user account

## Uninstallation
```bash
sudo bash ~/SSHToggle/ToggleSSH.sh --remove
```

## Technical Details
### Implementation Highlights
- 🏠 **Dynamic Paths:** Automatically detects user's home directory
- 💾 **Safe Config:** Creates `sshd_config.backup` before modifications
- 🐧 **Compatibility:** Works on SteamOS and most Linux distributions

### File Structure
```tree
bin/
├── Install.sh          # Main installer
├── ToggleSSH.sh        # Control script
└── ToggleSSH.desktop   # Launcher template
```

## FAQ
**Q:** Works on regular Linux?  
**A:** Yes! Detects any user's home directory automatically.

**Q:** How to check status?  
**A:** Run: `systemctl status sshd`

**Q:** Change SSH port?  
**A:** Edit `/etc/ssh/sshd_config` after installation

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SteamOS Compatible](https://img.shields.io/badge/SteamOS-Compatible-success)](https://store.steampowered.com/steamos)
![Bazzite.gg Compatible](https://img.shields.io/badge/Bazzite.gg-Compatible-success)
