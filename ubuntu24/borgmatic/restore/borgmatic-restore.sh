#!/bin/bash
set -euo pipefail

#################################################
#
#     Configuration (change these as needed)
#
#################################################
LOG_FILE="borgmatic-restore.log"

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][borgmatic-extract.sh]: $1" | tee -a "$LOG_FILE"
}

echo
log "Starting Borgmatic extract helper"

# Prompt for repo name
read -rp "Enter Borg repo path (or leave blank to use default config): " REPO

if [[ -z "$REPO" ]]; then
  log "Listing archives using default config"
  borgmatic list
else
  log "Listing archives for repository: $REPO"
  borgmatic list --repository "$REPO"
fi

# Prompt for archive name
read -rp "Enter archive name to extract from: " ARCHIVE
if [[ -z "$ARCHIVE" ]]; then
  log "No archive specified. Exiting."
  exit 1
fi

# Prompt for file/folder path inside the archive
read -rp "Enter path inside archive to extract (e.g., etc/nginx): " ARCHIVE_PATH
if [[ -z "$ARCHIVE_PATH" ]]; then
  log "No path in archive specified. Exiting."
  exit 1
fi

# Prompt for local destination
read -rp "Enter destination path on your system (e.g., /tmp/restore): " DEST_PATH
if [[ -z "$DEST_PATH" ]]; then
  log "No destination specified. Exiting."
  exit 1
fi

# Ensure destination directory exists
log "Creating destination directory if it doesn't exist: $DEST_PATH"
mkdir -p "$DEST_PATH"

# Extract files
log "Extracting '$ARCHIVE_PATH' from archive '$ARCHIVE' to '$DEST_PATH'"
if [[ -z "$REPO" ]]; then
  borgmatic extract --archive "$ARCHIVE" --path "$ARCHIVE_PATH" --destination "$DEST_PATH"
else
  borgmatic extract --repository "$REPO" --archive "$ARCHIVE" --path "$ARCHIVE_PATH" --destination "$DEST_PATH"
fi

# Done
log "
  Extraction complete!

  Files from '$ARCHIVE:$ARCHIVE_PATH' have been placed in:
  $DEST_PATH
"
