#!/bin/bash

color=true
loop=false
num=4

while [ $# -gt 0 ]; do
  case "$1" in
    -l | --loop ) loop=true;;
    -nc | --no-color ) color=false;;
    -n ) shift; num=$1;;
    -h )
      echo "Analyzes battery-time-data to approximate max run-time."
      echo "-l  --loop        repeat output after 30s, clears screen."
      echo "-nc  --no-color   do not color output"
      echo "-n N              process N files of data."
      exit;;
  esac
  shift
done


while true; do

  $loop && clear;

  cd `dirname $0`
  for f in `ls -t batteryTime.*.data | head -n $num`; do
    stat -c %y $f
    echo "$f"
    {
      granularity=`cat $f | grep '^Granularity' | sed 's/.*: \([0-9]*\)s/\1/'`
      counted=`cat $f | grep '^Counted' | sed 's/.*: \([0-9]*\)s/\1/'`
      elapsed=`cat $f | grep '^Elapsed' | sed 's/.*: \([0-9]*\)s/\1/'`
      started=`cat $f | grep '^Comment.*Started' | sed 's/.*: Started at \([0-9]*\)%.*/\1/'`
      current=`cat $f | grep '^Comment.*Currently' | sed 's/.*: Currently \([0-9]*\)%.*/\1/'`
      uptimeStart=`cat $f | grep '^Uptime @ start' | sed 's/.*: \([0-9.]*\)/\1/'`
      uptimeLast=`cat $f | grep '^Uptime   ' | sed 's/.*: \([0-9.]*\)/\1/'`
      [ "$uptimeStart" != "" ] && uptime=`echo "$uptimeLast-$uptimeStart" | bc -l`
      battery=`echo "$started-$current" | bc -l`
      echo -n "Time min (h)              : "
      echo "100/($battery+1)*$counted/3600" | bc -l || echo
      $color && tput bold
      echo -n "Time assumed (h)          : "
      [ "$battery" -gt 0 ] && echo "100/$battery*$counted/3600" | bc -l || echo
      $color && tput init
      echo -n "Time max (h)              : "
      [ "$battery" -gt 0 ] && echo "100/$battery*($counted+$granularity)/3600" | bc -l || echo
      if [ "$uptime" != "" ]; then
        echo -n "Time min (uptime, h)      : "
        echo "100/($battery+1)*$uptime/3600" | bc -l || echo
        $color && tput bold
        echo -n "Time assumed (uptime, h)  : "
        [ "$battery" -gt 0 ] && echo "100/$battery*$uptime/3600" | bc -l || echo
        $color && tput init
        echo -n "Time max (uptime, h)      : "
        [ "$battery" -gt 0 ] && echo "100/$battery*($uptime+0.001)/3600" | bc -l || echo
      fi
      echo -n "Length of measurement (h) : "
      echo "$elapsed/3600" | bc -l || echo
      echo "Battery used              : $battery %"
    } | sed 's/^/  /'
  done

  $loop || break
  echo "Refreshing in 30s."
  sleep 30s
  
done
