#!/bin/bash

# checks power management of wlan0 and disables it
#
# i'm not sure if laptop-mode does it on some notebooks or if some notebooks
# hardware have this issue themselves but it seems that on battery some
# notebooks have power-management turned on by default resulting in packet loss

if=wlan0

power=`iwconfig $if | grep -ie "power management"`
echo "$power"
echo "$power" | grep -qFe 'Power Management:off' && exit 0
echo "Turning power mgmt off..."
sudo iwconfig $if power off
iwconfig $if | grep -ie "power management"

