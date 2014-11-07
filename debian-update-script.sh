#!/bin/bash
#
#Modified by Stephen Reese http://www.rsreese.com
#Last Updated: 03/22/2011 
#Version 1.1 
#Latest version can be found at https://code.google.com/u/rsreese/
#
#Distributed under the New BSD License - http://www.opensource.org/licenses/bsd-license.html
#
#Copyright (c) 2007, Patrick Harrison
#All rights reserved.
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#    * Neither the name of the Monkey House Security nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
#CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#Modify these variables to match your system
OS_UP="yes"		#Set yes if source sync is desired
DEST="/backups/"
BACKUP_DIRS="/etc /var/www /var/log"
BACK_LNG="2"            #Length of backup retention
EMAIL="username@domain.com"
NTPSERVER="ntp-2.vt.edu"

#rsync backup
RSYNC_BACKUP="yes"
RHOST="0.0.0.0"
RUSER="username"
#Exclude a directory from backup
RSYNC_EX="test"
KEY="/home/username/.ssh/id_dsa"
# File to store current backup file
FILE=""

#Set yes if MySQL needs to be backed up
MYSQL_UP="yes"
MyUSER="root"           # MySQL USERNAME
MyPASS='password'     # MySQL PASSWORD
MyHOST="localhost"      # MySQL Hostname
DBS="" 			# Store list of databases
IGGY="test"  		# DO NOT BACKUP these databases

#The FILE_SIZE variable is set to locate files on the filesystem larger than a certain size.  
#This should be some number followed by a capital "M" to signify Megabytes.
FILE_SIZE="20M"

#Set to "yes" if /tmp directory cleanup is desired.  
#If TMP_CLEAN = "yes", then remember to set TMP_TIME variable to remove files older than X days.
TMP_CLEAN="no"
TMP_TIME="30"

#Set to "yes" if encrypted backups are desired.  
#If ENCRYPT = "yes", then remeber to set ENC_PASS as your password. 
ENCRYPT="yes"
ENC_PASS='My$uperS3cr3tPassw0rd'

#Most of these should work well...
HOST=`hostname -f`
YEST=`date --date yesterday +%b" "%_d`
NTPDATE="/usr/sbin/ntpdate"
WHICH="/usr/bin/which"
UNAME="$(which uname)"
UPTIME="$(which uptime)"
DF="$(which df)"
PS="$(which ps)"
GREP="$(which grep)"
NETSTAT="$(which netstat)"
VMSTAT="/usr/bin/vmstat"
FDISK="/sbin/fdisk"
CUT="/usr/bin/cut"
LYNX="/usr/bin/lynx"
LAST="/usr/bin/last"
TAR="/bin/tar"
RM="/bin/rm"
DATE="/bin/date"
LS="/bin/ls"
SED="/bin/sed"
AWK="/usr/bin/awk"
FIND="/usr/bin/find"
APT_GET="$(which apt-get)"
HEAD="/usr/bin/head"
TAIL="/usr/bin/tail"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
RSYNC="$(which rsync)"
SSH="$(which ssh)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"
SSMTP="/usr/sbin/sendmail"
OPENSSL="/usr/bin/openssl"
BACKUP_ENC_KEY="/etc/cron.daily/public.pem"
SVN="/usr/bin/svn"

echo "From: Updater@$HOST" > /tmp/update.log
echo "To: $EMAIL" >> /tmp/update.log
echo "Subject: Nightly Updates for $HOST" >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Kernel" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$UNAME -a >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Uptime" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$UPTIME >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Syncing Time Clock" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$NTPDATE $NTPSERVER  >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Checking Free Disk Space" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$DF -h >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Running Services"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$PS aux >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Listening Services"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$NETSTAT -lnv 2> /dev/null >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Traffic Stats"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$NETSTAT -s >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Process Statistics" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$VMSTAT -a >> /tmp/update.log
echo "" >> /tmp/update.log
$VMSTAT -s >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Disk Statistics" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
for DRIVE in `$FDISK -l | $GREP Linux | $CUT -f3 -d'/' | $CUT -f1 -d' '`
do
$VMSTAT -p $DRIVE >> /tmp/update.log
done
echo "Totals:" >> /tmp/update.log
$VMSTAT -d |$GREP -v loop >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "All files on the system larger than $FILE_SIZE" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$FIND / -type f -size +$FILE_SIZE -exec ls -lh --time-style='+%b %_d %Y' {} \; 2> /dev/null | $AWK '{ print $9 ": " $5 }' >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

#/tmp directory clean-up
#Set TMP_CLEAN variable above to "yes" to automatically clean up /tmp directory nightly
if [ $TMP_CLEAN = "yes" ]; then
echo "Purging the following files older than $TMP_TIME days from /tmp" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
cd /tmp/; $FIND . -mtime +$TMP_TIME -type f -exec ls -lh {} \; | $AWK '{ print $9 " -- " $6" "$7" "$8 }' >> /tmp/update.log
$FIND . -mtime +$TMP_TIME -type f -exec rm {} \;
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log
fi

echo "Yesterday's Logins"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$LAST | $GREP "$YEST" >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

if [ $MYSQL_UP = "yes" ]; then
echo "MySQL DUMP" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
DBS="$($MYSQL -u $MyUSER -h $MyHOST -p"$MyPASS" -Bse 'show databases')"
for db in $DBS
do
skipdb=-1
if [ "$IGGY" != "" ];
	then
	for i in $IGGY
do
[ "$db" == "$i" ] && skipdb=1 || :
done
fi
if [ "$skipdb" == "-1" ] ; then
FILE="$DEST$HOST.`$DATE +"%F"`.$db.mysql.tar.gz"
    if [ $ENCRYPT = "yes" ]; then
	$MYSQLDUMP --single-transaction -u $MyUSER -h $MyHOST -p"$MyPASS" $db > $db.sql && $TAR -czvf - $db.sql | $OPENSSL enc -aes-256-cbc -salt -out $FILE.enc -k $ENC_PASS && rm -f $db.sql
echo $db
echo $db.sql
echo $FILE
else
        $MYSQLDUMP --single-transaction -u $MyUSER -h $MyHOST -p"$MyPASS" $db > $db.sql && $TAR -czvf $FILE $db.sql && rm -f $db.sql
    fi
    fi
	done
fi
$LS -lht $DEST*.mysql.tar.gz >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Creating and Rotating Backups"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
if [ $ENCRYPT = "yes" ]; then
	for directory in ${BACKUP_DIRS}; do
		directory2=`echo ${directory} | sed 's,^/,,;s,/,-,g'`	
	$TAR czvf - ${directory} | $OPENSSL enc -aes-256-cbc -salt -out $DEST$HOST.`$DATE +"%F"`.${directory2}.tar.gz.enc -k $ENC_PASS
	done
else
	for directory in ${BACKUP_DIRS}; do
		directory2=`echo ${directory} | sed 's,^/,,;s,/,-,g'`
	${TAR} czvf ${DEST}${HOST}.`${DATE} +"%F"`.${directory2}.tar.gz ${directory}
   	done
fi
$FIND $DEST \( -name "*.gz" -o -name "*.enc" \) -mtime "+"$BACK_LNG -exec rm -f {} \;
$LS -lht $DEST >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

if [ $RSYNC_BACKUP = "yes" ]; then
echo "Sending backup to remote server via RSYNC/SSH" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$RSYNC -acvz --stats --delete --exclude $RSYNC_EX $DEST -e "$SSH -i $KEY" $RUSER@$RHOST:$DEST$HOST >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log
fi

if [ $OS_UP = "yes" ]; then
echo "Syncing Source Tree" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$APT_GET update >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log
fi

echo "Packages to be Upgraded!" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$APT_GET -Vs upgrade | perl -ne 'print if /upgraded:/ .. /upgraded,/' >> /tmp/update.log
$APT_GET -yqd upgrade > /dev/null
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "Kernel Sources" >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
echo "You currently have the following kernel sources installed:" >> /tmp/update.log
ls -ogh /usr/src/ >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "SSHD Messages From Yesterday"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$GREP "$YEST" /var/log/messages | $GREP sshd\\[ >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "/var/log/messages from Yesterday"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$GREP "$YEST" /var/log/messages | $GREP -v cron\\[ | $GREP -v sshd\\[ >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

echo "/var/log/syslog from Yesterday"  >> /tmp/update.log
echo "--------------------------------" >> /tmp/update.log
$GREP "$YEST" /var/log/syslog | $GREP -v cron\\[ | $GREP -v sshd\\[ >> /tmp/update.log
echo "" >> /tmp/update.log
echo "" >> /tmp/update.log

$SSMTP $EMAIL -fupdate@$HOST < /tmp/update.log

exit 0
