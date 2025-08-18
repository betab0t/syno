#!/bin/sh
# print core dump log with time stamp in /mnt/SD0 and /tmp

if [ "$1" == "" ]; then
	exit 0
fi

CORE_DUMP_LOG_TMP="/tmp/core_dump_log.txt"
CORE_DUMP_LOG_SD="/mnt/SD0/core_dump_log.txt"
TIME=`date +"%Y-%m-%d %H:%M:%S"`
CORE_DUMP_PROC_NAME=`echo $1 | cut -d'-' -f 2`
LOG="$CORE_DUMP_PROC_NAME core dumped at $TIME"

echo "$LOG" >> $CORE_DUMP_LOG_TMP
if [ -f $CORE_DUMP_LOG_TMP ]; then
	LINE_NUM=`wc -l < $CORE_DUMP_LOG_TMP`
	if [ "$LINE_NUM" -gt 500 ]; then
		echo "$(tail -500 $CORE_DUMP_LOG_TMP)" > $CORE_DUMP_LOG_TMP
	fi
fi

echo "$LOG" >> $CORE_DUMP_LOG_SD
if [ -f $CORE_DUMP_LOG_SD ]; then
	LINE_NUM=`wc -l < $CORE_DUMP_LOG_SD`
	if [ "$LINE_NUM" -gt 500 ]; then
		echo "$(tail -500 $CORE_DUMP_LOG_SD)" > $CORE_DUMP_LOG_SD
	fi
fi

exec /usr/bin/tee -i >"$1"