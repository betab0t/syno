#!/bin/sh
IFS=$'\n'
node_sd0=""
#node_usb0=""
if [ -e "/sys/block/mmcblk0" ]; then
	echo "found /sys/block/mmcblk0" > /dev/console
	if [ -e "/dev/mmcblk0p1" ]; then
		node_sd0="/dev/mmcblk0p1"
	elif [ -e "/dev/mmcblk0" ]; then
		node_sd0="/dev/mmcblk0"
	else
		node_sd0=""
		echo "cannot find mmcblk0p1 or mmcblk0!" > /dev/console
	fi
fi
if [ -e "/sys/block/mmcblk1" ]; then
	echo "not support to mount sdcard from mmc1!" > /dev/console
fi

if [ -S /tmp/ipc-system ]; then
	diag action=update "json={\"Dev\":{\"ID\":\"SD0\",\"DevNode\":\"$node_sd0\"}}"
	#diag action=update "json={\"Dev\":{\"ID\":\"USB0\",\"DevNode\":\"$node_usb0\"}}"
else
	echo "/tmp/ipc-system is not exist!" > /dev/console
fi

