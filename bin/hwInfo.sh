#!/bin/bash
sensors
acpi=`acpi`
echo "$acpi"
if echo "$acpi" | grep -iqFe 'discharging' && ! echo "$acpi" | grep -iqFe 'zero rate'; then
  echo -n 'Estimated full running time (h): '; echo "$acpi" | sed 's/.* \([0-9]*\)%, \([0-9]*\):\([0-9]*\):.*/100\/60*(\2*60+\3)\/\1/' | bc -l
fi
echo -n "Watt: "; echo `cat /sys/bus/acpi/drivers/battery/*/power_supply/*/power_now` / 1000000 | bc -l; 
sdxState.sh
echo ""
optirun --status
