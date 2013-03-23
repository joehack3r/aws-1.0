#!/usr/bin/env bash

#Script to backup mysql database
#Taken from http://swiftbend.com/blog/?page_id=55 (Backing up MySQL databases to Amazon S3)

#Run this to create MySQL backup user
#mysql -u root -p
#GRANT LOCK TABLES, SELECT, SHOW VIEW, RELOAD on *.* to backup@localhost IDENTIFIED BY 'password';
#FLUSH PRIVILEGES;

#Variables
export PATH=$PATH:$HOME/local/bin
tmpDir=/tmp
backupDate=$(date +%Y%m%d_%H%M%S)
mySqlUser=$1
mySqlPassword=$2
bucketName=$3
bucketPath=$4 # no leading slash

#Make sure tmpDir exists
if [ ! -e $tmpDir ]; then
  mkdir -p $tmpDir
fi

#Run the backup
mysqldump --tz-utc --all-databases --flush-privileges --log-error=$tmpDir/mysqldump_errors.log.$backupDate  --result-file=$tmpDir/mysqldump_all.dmp.$backupDate --user=$mySqlUser --password=$mySqlPassword || exit

#Compress the backup and log file
cd $tmpDir
tar czvf $tmpDir/mysqldump.dmp.$backupDate.tgz mysqldump_errors.log.$backupDate mysqldump_all.dmp.$backupDate
cd -

#Create file with latest.tgz suffix.  Will upload this .latest.tgz so we can easily restore from it
cp $tmpDir/mysqldump.dmp.$backupDate.tgz $tmpDir/mysqldump.dmp.latest.tgz

#Copy the backups to S3 bucket
uploadToS3.py $bucketName $bucketPath $tmpDir/mysqldump.dmp.$backupDate.tgz $tmpDir/mysqldump.dmp.latest.tgz

#Clean up the backup files
rm -f $tmpDir/mysqldump_errors.log.$backupDate $tmpDir/mysqldump_all.dmp.$backupDate $tmpDir/mysqldump.dmp.$backupDate.tgz $tmpDir/mysqldump.dmp.latest.tgz
