#!/bin/bash

# starts timeCounter.sh with output to batteryTimeCounter.*.data
# if discharging battery (according to acpi).
# kills started instances if not discharging.
# use in crontab to allow a battery-lifetime counting for your sessions
# use together with batteryTimeAnalysis.sh

cd `dirname "$0"`
acpi=`acpi`
percent=`echo "$acpi" | sed 's/.* \([0-9]*\)%.*/\1/'`
if echo "$acpi" | grep -qiFe 'discharging'; then
  if [ -f batteryTimeCounter.run ]; then
    {
      running=false
      while read pid; do
        if kill -0 $pid; then
          running=true
          break
        fi
        echo "Not running : $pid"
      done
      $running
    } < batteryTimeCounter.run && exit
  fi
  i=0;
  while [ -f "batteryTime.$i.data" ]; do
    let i=i+1
  done
  ccmd="echo -n 'Currently ' ; echo -n \`acpi | sed 's/.* \([0-9]*%\).*/\1/'\` battery."
  ./timeCounter.sh -q -o "batteryTime.$i.data" -c "Started at $percent% battery." --ccmd "$ccmd" &
  pid=$!; disown %%
  echo "$pid" >> batteryTimeCounter.run
  echo "Started timeCounter : $pid"
else
  if [ -f batteryTimeCounter.run ]; then
    {
      while read pid; do
        kill $pid;
        while kill -0 $pid; do sleep 1; done
        echo "Killed timeCounter : $pid"
      done
    } < batteryTimeCounter.run
    rm batteryTimeCounter.run
    false && {
      for f in `ls batteryTime.*.data`; do
        if ! grep -qe '^Stopped probably at [0-9]*% battery.$' $f; then
          echo "Stopped probably at $percent% battery." >> $f
          echo "Extended `pwd`/$f with battery-information."
        fi
      done
    }
  fi
fi
