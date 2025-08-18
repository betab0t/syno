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
		showmsg "prepare_upgrade.sh: stop $DAEMON_NAME"
		/etc/rc.d/init.d/$DAEMON_NAME stop
		sleep $WAIT_SEC
	else
		showmsg "prepare_upgrade.sh: $DAEMON_NAME is not running"
	fi
}

showmsg "prepare_upgrade.sh: start"

stop_daemon synoaid 1

stop_daemon synoactiond 1

stop_daemon recorder 1

stop_daemon mediad 1

stop_daemon streamd 5

stop_daemon nvtd 3

if [ -f /opt/onvif/onvifd ]; then
	showmsg "prepare_upgrade.sh: stop onvifd"
	/opt/onvif/onvifd.sh stop
	sleep 1
fi

rm -f /tmp/msg*

sync; echo 3 > /proc/sys/vm/drop_caches

showmsg "prepare_upgrade.sh: finish"
free
