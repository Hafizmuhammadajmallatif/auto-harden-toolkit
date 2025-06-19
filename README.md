# Auto Harden Toolkit

A beginner-friendly Linux system hardening script that applies essential security settings automatically.

## ✨ Features

✅ Disables root SSH login  
✅ Applies basic iptables firewall rules:
- Default DROP on INPUT/FORWARD
- Allow SSH on port 22
- Allow established and related connections
- Allow outbound traffic

✅ Secures sensitive file permissions (`/etc/passwd`, `/etc/shadow`)  
✅ Enforces minimum password length (12 characters)  
✅ Logs all actions to `/var/log/auto_harden_report.txt`  

## 📂 Files

- `auto_harden.sh` → The hardening script
- `/var/log/auto_harden_report.txt` → Output log with applied actions

## 🚀 How to use

```bash
sudo ./auto_harden.sh
