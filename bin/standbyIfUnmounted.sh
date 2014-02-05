#!/bin/bash

# puts sd* drives into standby when they are not mounted.
# if you have swap on another (unmounted) drive, it could be a bad idea to but this script into crontab, otherwise it might.
# you might want to use visudo to add this permission line:
#   %sudo ALL = NOPASSWD: /sbin/hdparm -y /dev/sd?

echo /dev/sd* | sed 's/\s/\n/g' | sed 's/[0-9]*$//' | sort | uniq | { while read dev; do
  if ! mount | grep "^$dev"; then
    echo "$dev is not mounted, sending to standby"
    sudo hdparm -y "$dev"
  fi
done; }
