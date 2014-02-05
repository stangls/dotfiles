#!/bin/bash

num=100

./batteryTimeAnalysis.sh -n 100 |grep "Time assumed (h" | sed 's/^.*:\s*//' | grep -ve '^\s*$' | { sum=0; num=0; while read n; do num=$(($num+1)); sum=$( echo "$sum+$n" | bc -l ); echo -n "|"; done; echo; echo "Num: $num"; echo "Avg: "$(echo "$sum/$num" | bc -l); }
