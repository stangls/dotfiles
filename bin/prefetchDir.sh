#!/bin/bash
if [ "$1" != "" ]; then dir="$1"; else dir="."; fi
if [ "$2" != "" ]; then timeOut="$2"; else timeOut="5"; fi
echo -n "Prefetching $dir ... "
timeout $timeOut /bin/bash -c "find \"$dir\" -type f -print0 | xargs -0 -P 0 -n 100 cat &>/dev/null" &>/dev/null
if [ "$?" = "0" ]; then
  echo "done."
else
  echo "incomplete."
fi
