# Borgmatic

[Borgmatic](https://torsion.org/borgmatic/) which leverages [Borg](https://borgbackup.readthedocs.io/en/stable/) for backups has been my go-to solution for backups for years. Borg is space efficient and provides client-side encryption capabilities.

My provider of choice for places to host my backups is [BorgBase](https://www.borgbase.com/) (don't worry I'm not even including an affiliate list). Since Borg is encrypting my backups before they hit BorgBase, I don't have to worry about them being read and BorgBase has proven to be reliable and responsive (I pointed out slight UI frustrations which their devs fixed within 48h).

They also provide easy to digest instructions on setting up the repos (which my script will run through) along with alerting and push-only SSH key based access.