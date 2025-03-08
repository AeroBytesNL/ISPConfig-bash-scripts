#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 client webdir"
  exit 1
fi

client="$1"
webdir="$2"

full_path="/var/www/clients/$client/$webdir"
user_group="web46:$client"

echo "I'm running in path: $full_path With user group: $user_group"
echo "Grab a beer, this will take some time...."
echo "Changing file permissions..."

find $full_path -type f -exec chmod 644 {} \;

if [ $? -eq 0 ]; then
  echo "Successfully changed file permissions :)"
else
  echo "Failed to change file permissions :("
  exit 1
fi

echo "Changing directory permissions..."

find $full_path -type d -exec chmod 755 {} \;

if [ $? -eq 0 ]; then
  echo "Successfully changed directory permissions :)"
else
  echo "Failed to change directory permissions :("
  exit 1
fi

echo "Going to change ownership, grab a beer, this will take some time...."

chown -R "$user_group" "$full_path"

# Checks if prev command was executed succesfully
if [ $? -eq 0 ]; then
  echo "Successfully changed ownership of $full_path to $user_group :)"
else
  echo "Failed to change ownership of $full_path :("
  exit 1
fi

echo "I'm done :)"

exit 0