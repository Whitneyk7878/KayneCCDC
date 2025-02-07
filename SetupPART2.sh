#!/bin/bash

# Update and install necessary packages
echo "Installing required packages..."
sudo yum install -y aide rkhunter auditd clamav clamd clamav-update

# Download and set up monitoring script
echo "Downloading monitoring script..."
sudo wget -O /usr/local/bin/monitor.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/master/Linux/General/monitor.sh
sudo chmod +x /usr/local/bin/monitor.sh

# Enable and start auditd
echo "Configuring auditd..."
sudo systemctl enable auditd
sudo systemctl start auditd

# Download audit rules and apply them
echo "Setting up audit rules..."
sudo wget -O audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/refs/heads/master/audit.rules
sudo rm -f /etc/audit/rules.d/audit.rules
sudo mv audit.rules /etc/audit/rules.d/
sudo auditctl -R /etc/audit/rules.d/audit.rules

# Configure ClamAV
echo "Configuring ClamAV..."
sudo sed -i '8s/^/#/' /etc/freshclam.conf
sudo freshclam

# Create DIFFING directory
echo "Creating DIFFING directory..."
sudo mkdir -p /root/DIFFING

# Generate baseline system information
echo "Generating baseline data..."
sudo lsof -i -n | grep "LISTEN" > /root/DIFFING/portdiffingBASELINE.txt
sudo ss -t state established > /root/DIFFING/connectiondiffingBASELINE.txt
sudo cat /root/.bashrc > /root/DIFFING/alias_diffingBASELINE.txt
sudo find / -type f -executable 2>/dev/null > /root/DIFFING/executables_diffingBASELINE.txt
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null; done > /root/DIFFING/cron_diffingBASELINE.txt
sudo cat /etc/shadow > /root/DIFFING/users_diffingBASELINE.txt

# Create hidden directory for compressed files
echo "Creating hidden directory..."
sudo mkdir -p /lib/.tarkov

# Archive and store system files
echo "Compressing and storing system files..."
sudo tar -czf /lib/.tarkov/system_backup.tar.gz /etc/shadow /etc/passwd /etc/fail2ban/ /etc/hosts /var/log /var/mail /var/spool/postfix/ /etc/postfix/ /etc/dovecot

echo "Setup complete."