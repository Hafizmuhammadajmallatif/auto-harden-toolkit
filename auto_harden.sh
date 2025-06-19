#!/bin/bash
clear
echo "==============================================="
echo "        Auto Harden Toolkit v0.1"
echo "        Author: HAFIZ MUHAMMAD AJMAL LATIF"
echo "==============================================="

# Initialize log
LOG_FILE="/var/log/auto_harden_report.txt"
echo "Auto Harden Toolkit started at $(date)" > $LOG_FILE

# Disable root SSH login
SSH_CONFIG="/etc/ssh/sshd_config"
if grep -q "^PermitRootLogin" $SSH_CONFIG; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
    echo "Updated existing PermitRootLogin setting to 'no'." >> $LOG_FILE
else
    echo "PermitRootLogin no" >> $SSH_CONFIG
    echo "Added PermitRootLogin no to sshd_config." >> $LOG_FILE
fi

systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

# Apply basic iptables rules without duplication
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
echo "Applied basic iptables firewall rules." >> $LOG_FILE

# Secure sensitive file permissions
chmod 644 /etc/passwd
chmod 640 /etc/shadow
echo "Set permissions: /etc/passwd (644), /etc/shadow (640)." >> $LOG_FILE

# Enforce minimum password length
LOGIN_DEFS="/etc/login.defs"
if grep -q "^PASS_MIN_LEN" $LOGIN_DEFS; then
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' $LOGIN_DEFS
else
    echo "PASS_MIN_LEN 12" >> $LOGIN_DEFS
fi
echo "Set minimum password length to 12." >> $LOG_FILE

# Enforce password complexity if cracklib present
if grep -q "pam_cracklib.so" /etc/pam.d/common-password; then
    sed -i 's/.*pam_cracklib.so.*/password requisite pam_cracklib.so retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
    echo "Updated PAM to require stronger passwords (at least 1 upper, lower, digit, special char)." >> $LOG_FILE
else
    echo "PAM cracklib not configured — skipping complexity rules." >> $LOG_FILE
fi

echo "Auto Harden Toolkit completed at $(date)" >> $LOG_FILE
echo "Please review $LOG_FILE for details of applied changes."

  
