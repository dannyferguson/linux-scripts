## Before running the script

There are a few things you need to do before running the script if you choose to use BorgBase.

The first one is to generate an SSH key on your server (if you don't already have one) and add it to BorgBase. For this I usually run `ssh-keygen -t ed25519` and then output it using `cat /root/.ssh/id_ed25519.pub` so that I can copy and paste it into the BorgBase interface

![borg-1.png](../../../_images/borg-1.png)

Then you want to create a repository. The first step is to set a name and region.

![borg-2.png](../../../_images/borg-2.png)

The second step is to setup your SSH Key. I like to use the append-only configuration because it means that my VPS or Dedi can't delete files from Borg, only append. Meaning even in a fully compromised situation I should be fine.

Now you might be telling yourself that this sounds space efficient and this is where compaction comes in. You can trigger server side compaction from the BorgBase UI periodically or manually. I like to do it manually from time to time. What compaction does is it runs the delete commands that the servers sent it (so basically in append-only, the client still tells the server what to delete, it just doesn't until compaction happens)

![borg-3.png](../../../_images/borg-3.png)

Next you can setup monitoring, I like to do 2 days. This will email you if the repository hasn't been updated in X days.

![borg-4.png](../../../_images/borg-4.png)

The compaction tab would let you enable server-side compaction on a schedule. I don't mess with that since I like to do it manually after I've confirmed my repos are Healthy and not compromised.

The Advanced tab allows you to turn things on like sftp but I've never needed this, so I also skip it. 

I then just hit "Add Repository" and copy the repository URL for use in this script.

![borg-5.png](../../../_images/borg-5.png)

The final step is to generate a secure password (I just use 1password) to use as the encryption passphrase. Save this somewhere as you will need it to decrypt the backups and for the script to setup the backups.

# Running the script

1. Edit the script to add your repository URL and encryption passphrase
2. Make the script executable by running `chmod +x borgmatic-install.sh`
3. Run the script using `./borgmatic-install.sh`

Once the installation is complete, you should run `borgmatic create --verbosity 2` to run the first backup manually and confirm its all good.

Once you confirm everything is good, you should automate it using cron. I typically edit cron using `crontab -e` and then use the following config
```text
# Run a backup every 6 hours and log output to /var/log/borgmatic.log
0 */6 * * * borgmatic create >> /var/log/borgmatic.log 2>&1

# Run a consistency check every Monday at 1:00 AM and log output to /var/log/borgmatic.log
0 1 * * 1 borgmatic check >> /var/log/borgmatic.log 2>&1
```

# Retention

The default retention with my config template and the above cronjobs is as follows:

```text
keep_hourly: 4
keep_daily: 7
keep_weekly: 4
keep_monthly: 12
keep_yearly: 1
```

This means:
* Hourly: Keep the 4 most recent backups (note: “hourly” refers to the backup we run every 6 hours).
* Daily: Keep the 7 most recent daily backups.
* Weekly: Keep the 4 most recent weekly backups.
* Monthly: Keep the 12 most recent monthly backups.
* Yearly: Keep the single most recent yearly backup.

**How retention works:** Borg doesn't pre-assign backups to categories. Instead, when pruning runs, it calculates which backups to keep by looking at all your backups and asking: "What's the most recent backup from each of the last 7 days? Last 4 weeks? Last 12 months?" The same backup can satisfy multiple rules (e.g., being both the newest daily and newest weekly backup). Any backups that don't meet a retention rule get deleted.