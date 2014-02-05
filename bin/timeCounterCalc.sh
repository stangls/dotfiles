#!/bin/bash
t=$1; p=$2 ;
echo -n 'Laufzeit bisher: '; echo $t/3600 | bc -l ; echo -n 'Prognose gesamt: '; echo "100/(100-$p)*$t/3600" | bc -l
