#!/bin/sh
echo $0 > /dev/console
printenv > /dev/console

mmc_no=`echo $DEVPATH |awk -F"[/.]" '{print $7}'`
case "$mmc_no" in
mmc0)
	id=SD0
	;;
*)
	echo "$0: DEVPATH=$DEVPATH,MDEV=$MDEV,DEVNAME=$DEVNAME" > /dev/console
	exit
	;;
esac

action=`echo $ACTION`
case "$action" in
add)
	echo "action=add" > /dev/console
	if [ -e "$PWD/${MDEV}p1" ]; then
		node=$PWD/${MDEV}p1
		echo "found $node" > /dev/console
	elif [ -e "$PWD/${MDEV}" ]; then
		node=$PWD/${MDEV}
		echo "found $node" > /dev/console
	else
		echo "cannot find mmcblk0p1 or mmcblk0!" > /dev/console
		exit
	fi
	;;
remove)
	echo "action=remove" > /dev/console
	node=
	;;
*)
	echo "action=$action ?" > /dev/console
	exit
	;;
esac

if [ -S /tmp/ipc-system ]; then
	diag action=update "json={\"Dev\":{\"ID\":\"$id\",\"DevNode\":\"$node\"}}"
else
	echo "/tmp/ipc-system is not exist!" > /dev/console
fi

