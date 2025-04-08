#!/bin/bash
set -euo pipefail

#################################################
#
#     Configuration (change these as needed)
#
#################################################
LOG_FILE="borgmatic-install.log"
REPO_URL="CHANGEME"
ENCRYPTION_PASSPHRASE="CHANGEME"

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][borgmatic-install.sh]: $1" | tee -a "$LOG_FILE"
}

# Validate configuration
if [[ "$REPO_URL" == "CHANGEME" || "$ENCRYPTION_PASSPHRASE" == "CHANGEME" ]]; then
  echo "Error: Please set REPO_URL and ENCRYPTION_PASSPHRASE in the script before running." >&2
  exit 1
fi

# Update repos and install borgmatic
log "Updating repos and installing borgmatic"
apt-get update && apt-get install -y borgmatic

# Generate the default borgmatic config
log "Generating the default borgmatic config"
borgmatic config generate

# Copying my borgmatic template over the default config
log "Replacing default config with my included template"
rm /etc/borgmatic/config.yaml
curl -fsSL https://raw.githubusercontent.com/dannyferguson/linux-scripts/refs/heads/master/ubuntu24/borgmatic/install/config.yaml -o /etc/borgmatic/config.yaml

# Replace placeholders in borgmatic config with actual values
log "Replacing placeholders in borgmatic config"
sed -i \
  -e "s|CHANGEME_REPO|$REPO_URL|g" \
  -e "s|CHANGEME_PASS|$ENCRYPTION_PASSPHRASE|g" \
  /etc/borgmatic/config.yaml

# Init repository
export BORG_PASSPHRASE="$ENCRYPTION_PASSPHRASE"
log "Initializing borg repository at $REPO_URL if not already initialized"
if ! borg info "$REPO_URL" > /dev/null 2>&1; then
  borg init --encryption=repokey-blake2 "$REPO_URL"
  log "Repository initialized successfully"
else
  log "Repository already initialized"
fi

# Validating Borgmatic config
log "Validating Borgmatic config"
borgmatic config validate

# Exporting key
SAFE_KEY_FILE="$(echo "$REPO_URL" | tr -d '/:@').txt"
log "Exporting key to $SAFE_KEY_FILE"
borg key export "$REPO_URL" "$SAFE_KEY_FILE"

# Done
log "

  Borgmatic setup complete!

  Next steps are to run \"borgmatic create --verbosity 2\" to run the first backup manually and make sure everything is good and then to add cronjobs to automate it (see repo README)

  Note: download \"$SAFE_KEY_FILE\", save it somewhere and delete it from the server. This can act as a backup of your encryption key.

"