#!/bin/sh

CYAN='\033[1;36m'
NC='\033[0m'

showmsg() {
	echo -e "${CYAN}$1${NC}"
}

# stop_daemon [daemon name] [wait seconds]
stop_daemon() {
	DAEMON_NAME=$1
	DAEMON_PID=`pidof $DAEMON_NAME`
	WAIT_SEC=$2

	if [ "$DAEMON_PID" != "" ]; then
		showmsg "pre-script.sh: stop $DAEMON_NAME"
		/etc/rc.d/init.d/$DAEMON_NAME stop
		sleep $WAIT_SEC
	else
		showmsg "pre-script.sh: $DAEMON_NAME is not running"
	fi
}

echo "I am pre-script" > /tmp/fwupgrade_test

stop_daemon synoaid 1

stop_daemon synoactiond 1

stop_daemon recorder 1

stop_daemon mediad 1

stop_daemon streamd 5

stop_daemon nvtd 3

if [ -f /opt/onvif/onvifd ]; then
	showmsg "pre-script.sh: stop onvifd"
	/opt/onvif/onvifd.sh stop
	sleep 1
fi

sync
echo 3 > /proc/sys/vm/drop_caches
sleep 3
free

build_num=`diag action=list key=Property.Firmware.SynoBuildNumber`
echo "ori_version=$build_num" > /data/app/upgrade_info
echo "need_exec_upgrader=true" >> /data/app/upgrade_info

sync

exit 0
