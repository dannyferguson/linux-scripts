# Borgmatic

[Borgmatic](https://torsion.org/borgmatic/) which leverages [Borg](https://borgbackup.readthedocs.io/en/stable/) for backups has been my go-to solution for backups for years. Borg is space efficient and provides client-side encryption capabilities.

My provider of choice for places to host my backups is [BorgBase](https://www.borgbase.com/) (don't worry I'm not even including an affiliate list). Since Borg is encrypting my backups before they hit BorgBase, I don't have to worry about them being read and BorgBase has proven to be reliable and responsive (I pointed out slight UI frustrations which their devs fixed within 48h).

They also provide easy to digest instructions on setting up the repos (which my script will run through) along with alerting and push-only SSH key based access.

My script backs up everything starting at / recursively except the following exceptions:
```yaml
exclude_patterns:
  - /dev  # Virtual devices
  - /proc # Kernel + process info (pseudo-filesystem)
  - /sys # Kernel + hardware info (pseudo-filesystem)
  - /tmp # Temporary files (cleared on reboot)
  - /run # Runtime data (sockets, PID files, etc.)
  - /mnt # Mounted storage (you might want this backed up, I do not)
  - /media # Mounted storage (you might want this backed up, I do not)
  - /lost+found # Filesystem recovery data
  - /var/lib/mysql # MySQL (you might want this backed up, I do but with mysqldump instead)
  - swapfile # Content in swap, not recoverable
  - swap.img # Content in swap, not recoverable
```
`/var/lib/mysql` is excluded because I prefer backing it up to (database).sql.gz files for easy backup/restore using my scripts at [MySQL Scripts](../../mysql)

The rest are typically ephemeral things you would not typically want backed up.