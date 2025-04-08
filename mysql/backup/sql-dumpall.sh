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
LOG_FILE="$BACKUP_DIR/mysql_backup.log"

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][sql-dumpall.sh]: $1" | tee -a "$LOG_FILE"
}

cd "$BACKUP_DIR" || exit 1
rm -rf "$BACKUP_DIR"/*.gz

log "Backing up all databases.."

HEAD=$(mktemp)
TAIL=$(mktemp)

cat > "$HEAD" <<EOF
SET autocommit=0;
SET unique_checks=0;
SET foreign_key_checks=0;
EOF

cat > "$TAIL" <<EOF
SET autocommit=1;
SET unique_checks=1;
SET foreign_key_checks=1;
EOF

dump_database() {
  local db="$1"
  log "Dumping $db ..."
  if mysqldump --single-transaction --skip-lock-tables -u "$MYSQL_USER" "$db" | cat "$HEAD" - "$TAIL" | gzip -fc > "$BACKUP_DIR/$db.sql.gz"; then
    log "Done dumping $db"
  else
    log "!! Failed to dump $db"
  fi
}

if [ -z "${1:-}" ]; then
  log "Dumping all databases ..."
  mapfile -t DBS < <(mysql -u "$MYSQL_USER" -e 'SHOW DATABASES' -s --skip-column-names)
  for DB in "${DBS[@]}"; do
    case "$DB" in
      information_schema|mysql|sys|phpmyadmin|performance_schema)
        log "Skipping $DB ..."
        continue
        ;;
      *)
        dump_database "$DB"
        ;;
    esac
  done
else
  dump_database "$1"
fi

rm -f "$HEAD" "$TAIL"

log "All databases dumped successfully!"
