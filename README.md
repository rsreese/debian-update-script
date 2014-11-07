## Debian Shell Script to update, backup and provide statistics for Debian systems.

* Shell script to update Debian system via APT.
* Backup systems and send the backups to remote systems
* MySQL backup
* Encrypted backups available
* System information like disc usage, network traffic
* Log file output from syslog 

Plan to add AWS S3 and Google Storage support.

### General:
I have grown quite accustom to receiving the daily email outputs from the fantastic /etc/daily, /etc/weekly, and /etc/month cronjobs. Now that I am supporting several Debian based servers, I find myself longing for that same system maintenance automation.

To addressed this, I have created a shell script for Debian to preform various nightly system administration tasks from a cron job and then email me a report.

### Install:

-Copy update-script.sh to the /etc/cron.daily/ directory on your Debian box.
-Optionally, to avoid having all Debian boxes attempt to update at the same time, edit /etc/crontab to reflect when the cron.daily jobs should run.

### Modify Backup Retention:

The variable `BACK_LNG` determines how long you want to keep backups. 

### Optional SSH/rsync backup:

To enable rsync usage with SSH first create a key, copy it to the remote system.

````
$ ssh-keygen -t dsa
$ ssh-copy-id -i ~/.ssh/id_dsa.pub ssh-user@remotehost.com
$ ssh ssh-user@remotehost.com
$ mkdir /backups/hostname
$ sudo chown ssh-user /backups/hostname.domain.com/
````

Run the script manually to accept the key for the first time and to ensure there are no errors.

Next you need to modify the variables for the rsync including enabling it, setting remote domain, remote user, key on local system, and if desired directory to exclude from backup.

### Optional MySQL Backup:

To enable MySQL backup, set the user, password, and host of the MySQL database. Secondly set the MySQL variable to yes. Each database will be backed up separately. 

### Optional Backup Encryption:

To enable AES-256 bit encryption of backups which is disabled by default, set the ENCRYPT variable = "yes". Next set the ENC_PASS variable to the password of your choosing. Note, this will also encrypt your MySQL database backups. Secondly, note that since this script will now hold your hardcoded backup passwords, please exercise proper caution when setting file permissions.

To decrypt your archived backup, issue the command:

`$ openssl enc -d -aes-256-cbc -in /backups/infile.tar.gz.enc -out outfile.tar.gz`

Substituting in the proper file-names and enter your password when prompted.
