# sql-dumpall.sh

This script backs up your MySQL database in a table per table basis. I purposefully set it up to ignore all the system (default) tables so that it doesn't backup users. This might not be convenient to everyone but I don't like backing up my users. 

I find backing up only my application data makes it easy to spin up a recovery instance of MySQL/MariaDB and just feed all my data back in it regardless of if its configured the exact same or not.

I tend to backup to `/home/backups/sql` on my installs but you can easily change that in the configuration section of the script.

To restore one of these backups, see [Restore Script](../Restore/README.md)