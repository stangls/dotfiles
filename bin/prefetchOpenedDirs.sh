#!/bin/bash

# check aprox every X seconds for newly opened directories
waitTime=5
# take a maximum of X seconds per directory to prefetch data
dirTime=5
# wait approximately 0.5 seconds between prefetching directories
dirWaitTime=0.5
# todo: cache old directories if nothing to do
#       but check memory fullness first
oldCache=true
# maximum memory fullness (in %)
maxUncached=60
memTooHigh=""

cd `dirname $0`

dirs=""
while true; do
  oldDirs="$dirs"
  dirs=`openDirectories.sh`
  uncached=$(
    free -m | grep '^Mem' | sed 's/Mem:\s\+\([0-9]\+\)\s\+\([0-9]\+\)\s\+\([0-9]\+\)\s\+\([0-9]\+\)\s\+\([0-9]\+\)\s\+\([0-9]\+\)/\1 \2 \3 \4 \5 \6/' | {
      read total used free shared buffers cached
      echo "($used-$cached)/$total*100" | bc -l | sed 's/\..*//'
      false && {
        echo -n "memory used     : "; echo "$used/$total" | bc -l
        echo -n "memory cached   : "; echo "$cached/$total" | bc -l
        echo -n "memory used but uncached : $uncached"; 
      } >&2
    }
  )
  if [ "$uncached" -gt "$maxUncached" ]; then
    if ! $memTooHigh || [ "$memTooHigh" = "" ]; then
      echo "uncached mem % too high : $uncached > $maxUncached"
      memTooHigh=true
    fi
  else
    if $memTooHigh; then
      echo "uncached mem % low enough : $uncached <= $maxUncached"
      memTooHigh=false
    fi
    {
      echo "$dirs"; echo
      echo "$oldDirs"; echo
      echo "$oldDirs"; echo
    } | sort | uniq -u | {
      processed=0
      while read dir; do
        if [ -d "$dir" ]; then
          [ "$processed" = "0" ] && echo ""
          ./prefetchDir.sh "$dir" $dirTime
          let processed=processed+1
          sleep $dirWaitTime
          continue
        fi
      done
      if [ "$processed" = 0 ]; then
        echo -n ''
      fi
    }
  fi
  sleep $waitTime
done
