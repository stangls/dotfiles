echo $(sensors | grep -e fan -e Core -e crit | sed 's/^.*:\s*\([^(]*\).*/\1/')
