#!/bin/bash
set -euo pipefail

#################################################
#
#     Configuration (change these as needed)
#
#################################################
MYSQL_USER="root"
# Optional: Run the below or uncomment it to set a password
# export MYSQL_PWD="yourpassword"
BACKUP_DIR="/home/backups/sql"
LOG_FILE="$BACKUP_DIR/mysql_restore.log"

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][sql-importall.sh]: $1" | tee -a "$LOG_FILE"
}

cd "$BACKUP_DIR" || exit 1

log "-- Restoring all databases --"

# Decompress .sql.gz files (keep original)
if compgen -G "*.sql.gz" > /dev/null; then
  log "-- Decompressing .sql.gz files ..."
  gunzip -fk *.sql.gz
fi

# Restore each .sql file
for f in *.sql; do
  DBNAME="${f%.sql}"
  log "-- Dropping database $DBNAME if it exists ..."
  mysql -u "$MYSQL_USER" -e "DROP DATABASE IF EXISTS \`$DBNAME\`;"

  log "-- Creating database $DBNAME ..."
  mysql -u "$MYSQL_USER" -e "CREATE DATABASE \`$DBNAME\`;"

  log "-- Importing $f into $DBNAME ..."
  mysql -u "$MYSQL_USER" "$DBNAME" < "$f"
done

log "-- All databases restored successfully --"
