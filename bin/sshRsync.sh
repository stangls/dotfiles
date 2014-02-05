#!/bin/bash

if [ "$1" = "" -o "$2" = "" ]; then
  echo "Rsyncs instead of scp with progress information and partial resume."
  echo "Usage: $0 [sshParams] FROM TO"
  echo "FROM and TO may be of the form user@host:dir"
  exit 0
fi

sshParams=""

while [ "$#" -gt 2 ]; do
  sshParams="$sshParams $1"
  shift
done

from="$1"
to="$2"

rsync -au --partial --progress --rsh="ssh$sshParams" "$from" "$to"

