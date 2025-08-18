#!/bin/sh

if [ "$1" == "" ]; then
	echo "Please input log file name."
	exit 1
fi

LOG=$1

if [ -f "$LOG" ]; then
	LINE_NUM=`wc -l < $LOG`
	if [ "$LINE_NUM" -gt 1000 ];then
		echo "$(tail -1000 $LOG)" > $LOG
		sync
	fi
fi
