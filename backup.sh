#!/bin/bash

# Set FTP server credentials
FTP_SERVER=""
FTP_USER=""
FTP_PASSWORD=""
FTP_DIR="/"

# Create a timestamped folder name (e.g., backup-2025-03-07-1500)
BACKUP_FOLDER=$(date +'%Y-%m-%d-%H%M')

# Create a backup folder in the FTP server
lftp -e "
open ftp://$FTP_USER:$FTP_PASSWORD@$FTP_SERVER;
cd $FTP_DIR;
mkdir $BACKUP_FOLDER;
bye
"

mysqldump -u root -p'' --all-databases > /tmp/all_databases.sql

tar -czf /tmp/web_data.tar.gz /var/www/
tar -czf /tmp/mail_data.tar.gz /var/vmail/

lftp -e "
open ftp://$FTP_USER:$FTP_PASSWORD@$FTP_SERVER;
cd $FTP_DIR/$BACKUP_FOLDER;
put /tmp/all_databases.sql;
put /tmp/web_data.tar.gz;
put /tmp/mail_data.tar.gz;
bye
"

rm /tmp/all_databases.sql
rm /tmp/web_data.tar.gz
rm /tmp/mail_data.tar.gz

# Check and delete old backups on FTP server
DAYS_TO_KEEP=7
lftp -e "
open ftp://$FTP_USER:$FTP_PASSWORD@$FTP_SERVER;
cd $FTP_DIR;
cls -1 | while read line; do
    if [[ -d \"\$line\" ]]; then
        # Get the folder timestamp
        folder_date=\$(echo \$line | sed 's/-//g')
        folder_timestamp=\$(date -d \"\$(echo \$folder_date | sed 's/\(....\)\(..\)\(..\)-\(..\)\(..\)/\1-\2-\3 \4:\5/')\" +'%s')
        current_timestamp=\$(date +'%s')
        age=\$(( (current_timestamp - folder_timestamp) / 86400 ))

        if [ \$age -ge $DAYS_TO_KEEP ]; then
            echo \"Deleting old backup: \$line\"
            rm -r \$line
        fi
    fi
done
bye
"