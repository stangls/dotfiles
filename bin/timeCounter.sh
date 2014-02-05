#!/bin/bash

# config
help=false
countUnit=10
outFile="timeData"
comment=""
commentCommand=""
clearUpdate=true
quiet=false
if [ -f "$outFile" ]; then
	echo "$outFile exists. Overwrite?"
	exit 1
fi

# params
while [ $# -gt 0 ]
do
	if [ "$1" == '--help' -o "$1" == '-h' ] ; then
		help=true
	elif [ "$1" == '-t' ] ; then
		shift
		countUnit="$1"
	elif [ "$1" == '-s' ] ; then
		clearUpdate=false
	elif [ "$1" == '-q' ] ; then
		quiet=true
		clearUpdate=false
	elif [ "$1" == '-c' ] ; then
    shift
		comment="$1"
	elif [ "$1" == '--ccmd' ] ; then
    shift
		commentCommand="$1"
	elif [ "$1" == '-o' ] ; then
		shift
		outFile="$1"
	else
		echo 'ERROR: Invalid param '$1
		help=true
	fi
	shift
done

# help screen
if $help; then
	echo ''
	echo 'Simple script to track actual run-time.'
	echo 'Useful for measuring active time of machine.'
	echo 'Waits a specific time (default: 10 seconds) and outputs time-information to the file "timeData"'
	echo ''
	echo '  -h , --help                  display help.'
	echo '  -t T                         change time-unit to T seconds'
	echo '  -nc                          do not clear the screen to print update information'
	echo '  -q                           do not output stuff'
	echo '                               only print it to file.'
	echo '  -o FN                        output data to FN instead of timeData'
	echo '  -c C                         output also comment C to the outfile.'
	echo '  --ccmd CMD                   output also the output of the command CMD to the outfile.'
	echo ''
	exit 0
fi


# functions
function showData(){
  [ "$comment" != "" ] && echo "Comment        : $comment"
  [ "$commentCommand" != "" ] && echo "CommentCommand : "`/bin/bash -c "$commentCommand"`
	echo "Granularity    : ${countUnit}s"
	echo "Start          : $startTime"
	echo "                 $startDate"
	if [ "$endTime" != "" ]; then
		echo "End            : $endTime"
		echo "                 $endDate"
		echo "Elapsed        : $(($endTime-$startTime))s"
	fi
	[ "$counted" != "" ] && echo "Counted        : $(($counted*$countUnit))s"
	[ "$counted" != "" -a "$endTime" != "" ] && echo "Difference     : $(($endTime-$startTime-$counted*$countUnit))s"
	[ "$timeSleep" != "" ] && echo "Approx sleep   : ${timeSleep}s (delayed)"
  echo "Uptime @ start : $uptimeStart"
  echo "Uptime         : `cat /proc/uptime | sed 's/ .*//'`"
}


function checkData(){
	endTime=`date +%s`
	endDate=`date`
	[ "$outFile" != "" ] && showData > "$outFile"
	if $clearUpdate; then
		clear; showData
	fi
}

function terminate(){
	checkData
	if $clearUpdate; then
		clear
	fi
	$quiet || showData
	exit 0
}
function step(){
	sleep "$countUnit"
	counted=$(($counted+1))
	checkData
}

# init
startTime=`date +%s`
startDate=`date`
uptimeStart=`cat /proc/uptime | sed 's/ .*//'`
trap "terminate" SIGINT SIGTERM

if $clearUpdate; then
	clear
fi
$quiet || showData

# main loop, approximating sleep-time of machine
timeSleep=0
counted=0
while true; do
	stepStartTime=`date +%s`
	step
	stepTime=$((`date +%s`-$stepStartTime))
	timeSleep=$(($timeSleep+$stepTime-$countUnit))
done
