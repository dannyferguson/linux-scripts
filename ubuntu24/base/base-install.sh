#!/bin/bash
set -euo pipefail

#################################################
#
#     Configuration (change these as needed)
#
#################################################
LOG_FILE="base-install.log"
TIMEZONE="America/Montreal"
SSH_CONFIG="/etc/ssh/sshd_config"
#GITHUB_USERNAME="dannyferguson"  # Uncomment and set to enable adding your Github SSH key to root

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][base-install.sh]: $1" | tee -a "$LOG_FILE"
}

# Set timezone
log "Setting timezone to $TIMEZONE"
timedatectl set-timezone "$TIMEZONE"

# Add Github SSH key to root
log "Adding Github SSH key to root if specified"
if [[ -n "${GITHUB_USERNAME:-}" ]]; then
  log "Ensuring Github SSH key for $GITHUB_USERNAME is added to root's authorized_keys"

  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
  AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
  GITHUB_KEY_URL="https://github.com/$GITHUB_USERNAME.keys"

  if curl -fsSL "$GITHUB_KEY_URL" > /tmp/github_keys; then
    while IFS= read -r key; do
      if ! grep -Fxq "$key" "$AUTHORIZED_KEYS" 2>/dev/null; then
        echo "$key" | tee -a "$AUTHORIZED_KEYS" > /dev/null
        log "Added Github key to root's authorized_keys"
      else
        log "Github key already present in root's authorized_keys"
      fi
    done < /tmp/github_keys
    rm -f /tmp/github_keys
  else
    log "Failed to fetch Github SSH keys for user $GITHUB_USERNAME"
  fi

  chmod 600 "$AUTHORIZED_KEYS"
else
  log "Github SSH key fetch is disabled (GITHUB_USERNAME not set)"
fi

# Update repos and already installed software
log "Updating repos and installed software"
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

# Setup basic UFW rules. Only adds the default SSH port (22)
log "Setting up basic UFW (firewall) rules"
ufw allow ssh
ufw --force enable

# Install useful utils
log "Installing htop, tmux, nload, ncdu, zip, unzip"
apt-get install -y htop tmux nload ncdu zip unzip

# Increase open file limit
log "Setting open file limits to 65535"
LIMITS_CONF="/etc/security/limits.conf"
if ! grep -q 'nofile' "$LIMITS_CONF"; then
  echo "* soft nofile 65535" | tee -a "$LIMITS_CONF" > /dev/null
  echo "* hard nofile 65535" | tee -a "$LIMITS_CONF" > /dev/null
else
  log "limits.conf already contains nofile settings"
fi

PAM_CONF="/etc/pam.d/common-session"
if ! grep -q 'pam_limits.so' "$PAM_CONF"; then
  echo "session required pam_limits.so" | tee -a "$PAM_CONF" > /dev/null
else
  log "pam_limits.so already configured"
fi

SYSCTL_CONF="/etc/sysctl.conf"
if ! grep -q 'fs.file-max' "$SYSCTL_CONF"; then
  echo "fs.file-max = 2097152" | tee -a "$SYSCTL_CONF" > /dev/null
else
  log "System-wide limit already set"
fi

log "Reloading sysctl configuration.."
sysctl -p > /dev/null

# Disable password based SSH logins (forcing you to use the more secure SSH keys)
log "Disabling password based SSH logins"

cp "$SSH_CONFIG" "$SSH_CONFIG.bak"

sed -i \
  -e 's/^#\?\s*PasswordAuthentication\s\+.*/PasswordAuthentication no/' \
  -e 's/^#\?\s*ChallengeResponseAuthentication\s\+.*/ChallengeResponseAuthentication no/' \
  -e 's/^#\?\s*KbdInteractiveAuthentication\s\+.*/KbdInteractiveAuthentication no/' \
  "$SSH_CONFIG"

grep -q '^PasswordAuthentication' "$SSH_CONFIG" || echo "PasswordAuthentication no" | tee -a "$SSH_CONFIG" > /dev/null
grep -q '^ChallengeResponseAuthentication' "$SSH_CONFIG" || echo "ChallengeResponseAuthentication no" | tee -a "$SSH_CONFIG" > /dev/null
grep -q '^KbdInteractiveAuthentication' "$SSH_CONFIG" || echo "KbdInteractiveAuthentication no" | tee -a "$SSH_CONFIG" > /dev/null

systemctl restart ssh

log "Base install script completed successfully. Its suggested to reboot for things like the open file limits and timezone changes to fully kick in."