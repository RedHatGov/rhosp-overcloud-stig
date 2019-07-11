# This script was written by Frank Caviggia, Red Hat Consulting
# Last update was 14 Apri 2017
# This script is NOT SUPPORTED by Red Hat Global Support Services.
# Please contact Rick Tavares for more information.
#
# Script: ssg-suplemental.sh (system-hardening)
# Description: RHEL 7 Hardening Supplemental to SSG
# License: GPL (see COPYING)
# Copyright: Red Hat Consulting, March 2015
# Author: Frank Caviggia <fcaviggi (at) redhat.com>

########################################
# LEGAL BANNER CONFIGURATION
########################################
BANNER_MESSAGE_TEXT='You are accessing a U.S. Government (USG) Information System (IS) that is \nprovided for USG-authorized use only. By using this IS (which includes any \ndevice attached to this IS), you consent to the following conditions:\n\n-The USG routinely intercepts and monitors communications on this IS for \npurposes including, but not limited to, penetration testing, COMSEC monitoring, \nnetwork operations and defense, personnel misconduct (PM), law enforcement \n(LE), and counterintelligence (CI) investigations.\n\n-At any time, the USG may inspect and seize data stored on this IS.\n\n-Communications using, or data stored on, this IS are not private, are subject \nto routine monitoring, interception, and search, and may be disclosed or used \nfor any USG-authorized purpose.\n\n-This IS includes security measures (e.g., authentication and access controls) \nto protect USG interests -- not for your personal benefit or privacy.\n\n-Notwithstanding the above, using this IS does not constitute consent to PM, LE \nor CI investigative searching or monitoring of the content of privileged \ncommunications, or work product, related to personal representation or services \nby attorneys, psychotherapists, or clergy, and their assistants. Such \ncommunications and work product are private and confidential. See User \nAgreement for details.\n\n'
echo -e "${BANNER_MESSAGE_TEXT}" > /etc/issue
echo -e "${BANNER_MESSAGE_TEXT}" > /etc/issue.net

########################################
# DISA STIG PAM Configurations
########################################
cat <<EOF > /etc/pam.d/system-auth-local
#%PAM-1.0
auth required pam_env.so
auth required pam_lastlog.so inactive=35
auth required pam_faillock.so preauth silent audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth sufficient pam_unix.so try_first_pass
auth [default=die] pam_faillock.so authfail audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth sufficient pam_faillock.so authsucc audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth requisite pam_succeed_if.so uid >= 1000 quiet
auth required pam_deny.so

account required pam_faillock.so
account required pam_unix.so
account required pam_lastlog.so inactive=35
account sufficient pam_localuser.so
account sufficient pam_succeed_if.so uid < 1000 quiet
account required pam_permit.so

# Password Quality now set in /etc/security/pwquality.conf
password required pam_pwquality.so retry=3
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=24
password required pam_deny.so

session required pam_lastlog.so showfailed
session optional pam_keyinit.so revoke
session required pam_limits.so
-session optional pam_systemd.so
session [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session required pam_unix.so
EOF
ln -sf /etc/pam.d/system-auth-local /etc/pam.d/system-auth
cp -f /etc/pam.d/system-auth-local /etc/pam.d/system-auth-ac

cat <<EOF > /etc/pam.d/password-auth-local
#%PAM-1.0
auth required pam_env.so
auth required pam_lastlog.so inactive=35
auth required pam_faillock.so preauth silent audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth sufficient pam_unix.so try_first_pass
auth [default=die] pam_faillock.so authfail audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth sufficient pam_faillock.so authsucc audit deny=3 even_deny_root root_unlock_time=900 unlock_time=604800 fail_interval=900
auth requisite pam_succeed_if.so uid >= 1000 quiet
auth required pam_deny.so

account required pam_faillock.so
account required pam_unix.so
account required pam_lastlog.so inactive=35
account sufficient pam_localuser.so
account sufficient pam_succeed_if.so uid < 1000 quiet
account required pam_permit.so

# Password Quality now set in /etc/security/pwquality.conf
password required pam_pwquality.so retry=3
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=24
password required pam_deny.so

session required pam_lastlog.so showfailed
session optional pam_keyinit.so revoke
session required pam_limits.so
-session optional pam_systemd.so
session [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session required pam_unix.so
EOF
ln -sf /etc/pam.d/password-auth-local /etc/pam.d/password-auth
cp -f /etc/pam.d/password-auth-local /etc/pam.d/password-auth-ac

cat <<EOF > /etc/security/pwquality.conf
# Configuration for systemwide password quality limits
# Defaults:
#
# Number of characters in the new password that must not be present in the
# old password.
# difok = 5
difok = 15
#
# Minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default). (See pam_cracklib manual.)
# Cannot be set to lower value than 6.
# minlen = 9
minlen = 15
#
# The maximum credit for having digits in the new password. If less than 0
# it is the minimum number of digits in the new password.
# dcredit = 1
dcredit = -1
#
# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimum number of uppercase characters in the new
# password.
# ucredit = 1
ucredit = -1
#
# The maximum credit for having lowercase characters in the new password.
# If less than 0 it is the minimum number of lowercase characters in the new
# password.
# lcredit = 1
lcredit = -1
#
# The maximum credit for having other characters in the new password.
# If less than 0 it is the minimum number of other characters in the new
# password.
# ocredit = 1
ocredit = -1
#
# The minimum number of required classes of characters for the new
# password (digits, uppercase, lowercase, others).
minclass = 4
#
# The maximum number of allowed consecutive same characters in the new password.
# The check is disabled if the value is 0.
maxrepeat = 2
#
# The maximum number of allowed consecutive characters of the same class in the
# new password.
# The check is disabled if the value is 0.
maxclassrepeat = 2
#
# Whether to check for the words from the passwd entry GECOS string of the user.
# The check is enabled if the value is not 0.
# gecoscheck = 0
#
# Path to the cracklib dictionaries. Default is to use the cracklib default.
# dictpath =
EOF

echo -e "FAIL_DELAY\t4" >> /etc/login.defs
echo -e "CREATE_HOME\tyes" >> /etc/login.defs


########################################
# STIG Audit Configuration
########################################
cat <<EOF > /etc/audit/rules.d/audit.rules
# DISA STIG Audit Rules
## Add keys to the audit rules below using the -k option to allow for more 
## organized and quicker searches with the ausearch tool.  See auditctl(8) 
## and ausearch(8) for more information.

# Remove any existing rules
-D

# Increase kernel buffer size
-b 16384

# Failure of auditd causes a kernel panic
-f 2

###########################
## DISA STIG Audit Rules ##
###########################

# Watch syslog configuration
-w /etc/rsyslog.conf
-w /etc/rsyslog.d/

# Watch PAM and authentication configuration
-w /etc/pam.d/
-w /etc/nsswitch.conf

# Watch system log files
-w /var/log/messages
-w /var/log/audit/audit.log
-w /var/log/audit/audit[1-4].log

# Watch audit configuration files
-w /etc/audit/auditd.conf -p wa
-w /etc/audit/audit.rules -p wa

# Watch login configuration
-w /etc/login.defs
-w /etc/securetty
-w /etc/resolv.conf

# Watch cron and at
-w /etc/at.allow
-w /etc/at.deny
-w /var/spool/at/
-w /etc/crontab
-w /etc/anacrontab
-w /etc/cron.allow
-w /etc/cron.deny
-w /etc/cron.d/
-w /etc/cron.hourly/
-w /etc/cron.weekly/
-w /etc/cron.monthly/

# Watch shell configuration
-w /etc/profile.d/
-w /etc/profile
-w /etc/shells
-w /etc/bashrc
-w /etc/csh.cshrc
-w /etc/csh.login

# Watch kernel configuration
-w /etc/sysctl.conf
-w /etc/modprobe.conf

# Watch linked libraries
-w /etc/ld.so.conf -p wa
-w /etc/ld.so.conf.d/ -p wa

# Watch init configuration
-w /etc/rc.d/init.d/
-w /etc/sysconfig/
-w /etc/inittab -p wa
-w /etc/rc.local
-w /usr/lib/systemd/
-w /etc/systemd/

# Watch filesystem and NFS exports
-w /etc/fstab
-w /etc/exports

# Watch xinetd configuration
-w /etc/xinetd.conf
-w /etc/xinetd.d/

# Watch Grub2 configuration
-w /etc/grub2.cfg
-w /etc/grub.d/

# Watch TCP_WRAPPERS configuration
-w /etc/hosts.allow
-w /etc/hosts.deny

# Watch sshd configuration
-w /etc/ssh/sshd_config

# Watch sudoers configuration
-w /etc/sudoers -p wa -k privileged-actions 
-w /etc/sudoers.d/ -p wa -k privileged-actions

# Audit system events
-a always,exit -F arch=b32 -S acct -S reboot -S sched_setparam -S sched_setscheduler -S setrlimit -S swapon 
-a always,exit -F arch=b64 -S acct -S reboot -S sched_setparam -S sched_setscheduler -S setrlimit -S swapon 

# Audit any link creation
-a always,exit -F arch=b32 -S link -S symlink
-a always,exit -F arch=b64 -S link -S symlink

#####################
# DISA Requirements #
#####################
# xccdf_mil.disa.stig_rule_SV-86747r2_rule
-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86749r2_rule
-a always,exit -F arch=b32 -S open -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86751r2_rule
-a always,exit -F arch=b32 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86753r2_rule
-a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86755r2_rule
-a always,exit -F arch=b32 -S truncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S truncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86757r2_rule
-a always,exit -F arch=b32 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access 
-a always,exit -F arch=b64 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
# xccdf_mil.disa.stig_rule_SV-86765r4_rule
-a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=1000 -F auid!=4294967295 -k -F privileged-priv_change

##############################
## NIST 800-53 Requirements ##
##############################

#2.6.2.4.1 Records Events that Modify Date and Time Information
-a always,exit -F arch=b32 -S adjtimex -S stime -S settimeofday -S clock_settime -k time-change
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

#2.6.2.4.2 Record Events that Modify User/Group Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

#2.6.2.4.3 Record Events that Modify the Systems Network Environment
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k audit_network_modifications
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k audit_network_modifications
-w /etc/issue -p wa -k audit_network_modifications
-w /etc/issue.net -p wa -k audit_network_modifications
-w /etc/hosts -p wa -k audit_network_modifications
-w /etc/sysconfig/network -p wa -k audit_network_modifications

#2.6.2.4.4 Record Events that Modify the System Mandatory Access Controls
-w /etc/selinux/ -p wa -k MAC-policy

#2.6.2.4.5 Ensure auditd Collects Logon and Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

#2.6.2.4.6 Ensure auditd Collects Process and Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

#2.6.2.4.12 Ensure auditd Collects System Administrator Actions
-w /etc/sudoers -p wa -k actions

#2.6.2.4.13 Make the auditd Configuration Immutable
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# Ignore all the anonymous events. Often tagged on every rule, but ignoring 
# up front should improve processing time
-a exit,never -F auid=4294967295
# Ignore system services
-a exit,never -F auid<1000

#2.6.2.4.7 Ensure auditd Collects Discretionary Access Control Permission Modification Events
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -k perm_mod
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -k perm_mod

#2.6.2.4.8 Ensure auditd Collects Unauthorized Access Attempts to Files (unsuccessful)
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -k access

#2.6.2.4.9 Ensure auditd Collects Information on the Use of Privileged Commands
-a always,exit -F path=/usr/sbin/semanage -F perm=x -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F key=privileged-priv_change
-a always,exit -F path=/usr/bin/chcon -F perm=x -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/restorecon -F perm=x -F key=privileged-priv_change
-a always,exit -F path=/usr/bin/userhelper -F perm=x -F key=privileged
-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F key=privileged
-a always,exit -F path=/usr/libexec/pt_chown -F perm=x -F key=privileged

EOF
# Find all privileged commands and monitor them
for fs in $(awk '($3 ~ /(ext[234])|(xfs)/) {print $2}' /proc/mounts) ; do
	find $fs -xdev -type f \( -perm -4000 -o -perm -2000 \) | awk '{print "-a always,exit -F path=" $1 " -F perm=x -k privileged" }' >> /etc/audit/rules.d/audit.rules
done
cat <<EOF >> /etc/audit/rules.d/audit.rules

#2.6.2.4.10 Ensure auditd Collects Information on Exporting to Media (successful)
-a always,exit -F arch=b32 -S mount -k export
-a always,exit -F arch=b64 -S mount -k export

#2.6.2.4.11 Ensure auditd Collects Files Deletion Events by User (successful and unsuccessful)
-a always,exit -F arch=b32 -S unlink -S rmdir -S unlinkat -S rename -S renameat -k delete
-a always,exit -F arch=b64 -S unlink -S rmdir -S unlinkat -S rename -S renameat -k delete

#2.6.2.4.14 Make the auditd Configuration Immutable
-e 2
EOF


########################################
# Fix cron.allow
########################################
echo "root" > /etc/cron.allow
chmod 400 /etc/cron.allow
chown root:root /etc/cron.allow


########################################
# Make SELinux Configuration Immutable
########################################
chattr +i /etc/selinux/config


########################################
# Disable Control-Alt-Delete
########################################
ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target


########################################
# No Root Login to Console (Use admin)
########################################
cat /dev/null > /etc/securetty

########################################
# Disable Interactive Shell (Timeout)
########################################
cat <<EOF > /etc/profile.d/autologout.sh
#!/bin/sh
TMOUT=900
export TMOUT
readonly TMOUT
EOF
cat <<EOF > /etc/profile.d/autologout.csh
#!/bin/csh
set autologout=15
set -r autologout
EOF
chown root:root /etc/profile.d/autologout.sh
chown root:root /etc/profile.d/autologout.csh
chmod 755 /etc/profile.d/autologout.sh
chmod 755 /etc/profile.d/autologout.csh


#########################################
# Set Shell UMASK Setting (027)
########################################
cat <<EOF > /etc/profile.d/umask.sh
#!/bin/sh

# Non-Privileged Users get 027
# Privileged Users get 022
if [[ \$EUID -ne 0 ]]; then
	umask 027
else
	umask 022
fi
EOF
cat <<EOF > /etc/profile.d/umask.csh
#!/bin/csh
umask 027
EOF
chown root:root /etc/profile.d/umask.sh
chown root:root /etc/profile.d/umask.csh
chmod 555 /etc/profile.d/umask.sh
chmod 555 /etc/profile.d/umask.csh


########################################
# Vlock Alias (Cosole Screen Lock)
########################################
cat <<EOF > /etc/profile.d/vlock-alias.sh
#!/bin/sh
alias vlock='clear;vlock -a'
EOF
cat <<EOF > /etc/profile.d/vlock-alias.csh
#!/bin/csh
alias vlock 'clear;vlock -a'
EOF
chown root:root /etc/profile.d/vlock-alias.sh
chown root:root /etc/profile.d/vlock-alias.csh
chmod 755 /etc/profile.d/vlock-alias.sh
chmod 755 /etc/profile.d/vlock-alias.csh


########################################
# Wheel Group Require (sudo)
########################################
sed -i -re '/pam_wheel.so use_uid/s/^#//' /etc/pam.d/su
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/' /etc/sudoers
echo -e "\n## Set timeout for authentication (5 Minutes)\nDefaults:ALL timestamp_timeout=5\n" >> /etc/sudoers


########################################
# Set Removeable Media to noexec
#   CCE-27196-5
########################################
for DEVICE in $(/bin/lsblk | grep sr | awk '{ print $1 }'); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,noauto,nosuid,nodev\t0 0" >> /etc/fstab
done
for DEVICE in $(cd /dev;ls *cd* *dvd*); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,noauto,nosuid,nodev\t0 0" >> /etc/fstab
done


########################################
# SSHD Hardening
########################################
sed -i '/Ciphers.*/d' /etc/ssh/sshd_config
sed -i '/MACs.*/d' /etc/ssh/sshd_config
sed -i '/Protocol.*/d' /etc/ssh/sshd_config
sed -i '/GSSAPIAuthentication.*/d' /etc/ssh/sshd_config
sed -i '/#Banner.*/d' /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
if [ $(grep -c sshusers /etc/group) -eq 0 ]; then
	/usr/sbin/groupadd sshusers &> /dev/null
fi


########################################
# Filesystem Attributes
#  CCE-26499-4,CCE-26720-3,CCE-26762-5,
#  CCE-26778-1,CCE-26622-1,CCE-26486-1.
#  CCE-27196-5
########################################
FSTAB=/etc/fstab
SED=`which sed`

if [ $(grep " \/sys " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/sys " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/sys.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/boot " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/boot " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/boot.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/export\/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/export\/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/export\/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr\/local " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr\/local " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr\/local.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/dev\/shm " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/dev\/shm " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/dev\/shm.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log\/audit " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/log\/audit " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/log\/audit.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/www " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/wwww " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/www.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/opt " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/opt " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/opt.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
echo -e "tmpfs\t\t\t/dev/shm\t\ttmpfs\tnoexec,nosuid,nodev\t\t0 0" >> /etc/fstab


########################################
# File Ownership 
########################################
cat <<EOF > /etc/cron.daily/unowned_files
#!/bin/sh
# Fix user and group ownership of files without user
find / -nouser -print | xargs chown root
find / -nogroup -print | xargs chown :root
EOF
chown root:root /etc/cron.daily/unowned_files
chmod 0700 /etc/cron.daily/unowned_files

########################################
# USGCB Blacklist
########################################
if [ -e /etc/modprobe.d/usgcb-blacklist.conf ]; then
	rm -f /etc/modprobe.d/usgcb-blacklist.conf
fi
touch /etc/modprobe.d/usgcb-blacklist.conf
chmod 0644 /etc/modprobe.d/usgcb-blacklist.conf
chcon 'system_u:object_r:modules_conf_t:s0' /etc/modprobe.d/usgcb-blacklist.conf

cat <<EOF > /etc/modprobe.d/usgcb-blacklist.conf
# Disable Bluetooth
install bluetooth /bin/true
# Disable AppleTalk
install appletalk /bin/true
# NSA Recommendation: Disable mounting USB Mass Storage
install usb-storage /bin/true
# Disable mounting of cramfs CCE-14089-7
install cramfs /bin/true
# Disable mounting of freevxfs CCE-14457-6
install freevxfs /bin/true
# Disable mounting of hfs CCE-15087-0
install hfs /bin/true
# Disable mounting of hfsplus CCE-14093-9
install hfsplus /bin/true
# Disable mounting of jffs2 CCE-14853-6
install jffs2 /bin/true
# Disable mounting of squashfs CCE-14118-4
install squashfs /bin/true
# Disable mounting of udf CCE-14871-8
install udf /bin/true
# CCE-14268-7
install dccp /bin/true
# CCE-14235-5
install sctp /bin/true
#i CCE-14027-7
install rds /bin/true
# CCE-14911-2
install tipc /bin/true
# CCE-14948-4 (row 176)
install net-pf-31 /bin/true
EOF


########################################
# Kernel - Randomize Memory Space
# CCE-27127-0, SC-30(2), 1.6.1
########################################
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf

########################################
# Kernel - Disable TCP Timestamps
#######################################
echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf

#######################################
# Kernel - Disable Syncookies
#######################################
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf

########################################
# Disable Kernel Dump Service
########################################
systemctl disable kdump.service
systemctl mask kdump.service

#######################################
# Fix Pam
#######################################
echo "password required pam_pwquality.so retry=3" >> /etc/pam.d/passwd

####################
# Fix repo_gpgcheck
####################
sed -i "s/repo_gpgcheck=1/repo_gpgcheck=0/g" /etc/yum.conf

###################
# Fix 
sed -i "s/crypt_style = md5/crypt_style = sha512/g" /etc/libuser.conf


