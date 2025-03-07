#!/bin/bash

# Set FTP server credentials
FTP_SERVER=""
FTP_USER=""
FTP_PASSWORD=""
FTP_DIR="/"

mysqldump -u root -p'' --all-databases > /tmp/all_databases.sql

tar -czf /tmp/ispconfig_config.tar.gz /etc/ispconfig/
tar -czf /tmp/web_data.tar.gz /var/www/
tar -czf /tmp/mail_data.tar.gz /var/vmail/

lftp -e "
open ftp://$FTP_USER:$FTP_PASSWORD@$FTP_SERVER;
cd $FTP_DIR;
put /tmp/ispconfig_database.sql;
put /tmp/ispconfig_config.tar.gz;
put /tmp/web_data.tar.gz;
put /tmp/mail_data.tar.gz;
bye
"

rm /tmp/ispconfig_database.sql
rm /tmp/ispconfig_config.tar.gz
rm /tmp/web_data.tar.gz
rm /tmp/mail_data.tar.gz
