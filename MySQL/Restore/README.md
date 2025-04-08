# sql-importall.sh

This script takes the output of the [Backup Script](../Backup/README.md) and restores it.

It uses the file names as the databases to drop and restore into. For example `test.sql` will drop and restore the database called `test`

**Warning: This performs a clean restore, meaning it will drop the database before recreating it and importing the data from the backup**