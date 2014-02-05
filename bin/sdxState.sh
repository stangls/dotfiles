#!/bin/bash

# shows the drive state of sd* devices (drives)
# you might want to use visudo to add this permission line:
#   %sudo ALL = NOPASSWD: /sbin/hdparm -C /dev/sd?

echo /dev/sd* | sed 's/\s/\n/g' | sed 's/[0-9]*$//' | sort | uniq | { while read dev; do
  echo -n "$dev"
  sudo hdparm -C "$dev" 2>/dev/null | grep 'drive state'
done; }
