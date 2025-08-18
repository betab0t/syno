#!/bin/sh
# chkconfig: 2345 95 05

prog=onvifd
binpath=/opt/onvif/$prog
pidfile=/tmp/run/"$prog".pid
default_net_interface=eth0

start()
{
	# restore onvif.json back to /data/app when the file is different or not exist to prevent writing flash every time.
	restore='0'
	if [ -f /data/app/onvif.json ]; then 
		cp /data/app/onvif.json /tmp/onvif.json; 
	else
		restore='1'
		cp /opt/onvif/default/onvif.json /tmp/onvif.json; 
	fi;

	if [ -f /data/app/onvif.json ]; then restore=`diff /data/app/onvif.json /tmp/onvif.json | wc -l`; fi;
	if [ $restore != '0' ]; then cp /tmp/onvif.json /data/app/onvif.json; echo "check_flash_write: /data/app/onvif.json"; fi;
	rm -rf /tmp/onvif.json

	[ -f /data/app/onvif-user.json ] || cp /opt/onvif/default/onvif-user.json /data/app && echo "check_flash_write: /data/app/onvif.json"

	if [ $default_net_interface == "" ]; then
		if [ -f /sys/class/net/eth0/carrier ]; then eth0_carrier=`cat /sys/class/net/eth0/carrier`; else eth0_carrier='0'; fi;
		if [ -f /sys/class/net/wlan0/carrier ]; then wlan0_carrier=`cat /sys/class/net/wlan0/carrier`; else wlan0_carrier='0'; fi;
		if [ $eth0_carrier == '1' ]; then
			ifname="eth0"
		elif [ $wlan0_carrier == '1' ]; then
			ifname="wlan0"
		else
			ifname="eth0"
		fi
	else
		ifname=$default_net_interface
	fi

	echo "Start $prog ..."
	echo "should update path of onvifd to /bin/onvifd"
	start-stop-daemon --start -n $prog --make-pidfile --pidfile $pidfile --exec $binpath -- -i $ifname &
}

stop()
{
	echo "Stop $prog ..."
	killall wsdd
	start-stop-daemon --stop --quiet -n $prog --exec $binpath --pidfile $pidfile

	# wait prog stop, kill it if timeout.
	while true
	do
		PROG_PID=`pidof $binpath`
		if [ "$PROG_PID" != "" ]; then
			if [ $wait_time -gt 0 ]; then
				echo "Wait $prog stop...$wait_time"
				let "wait_time--"
			else
				echo "Wait $prog stop...$wait_time, kill pid ($PROG_PID)!"
				killall -9 $binpath
			fi
			sleep 1
		else
			echo "Wait $prog stop done"
			break
		fi
	done
}

reload()
{
	echo "Reload $prog ..."
}

restart()
{
	stop
	sleep 1
	start
}

case "$1" in
	start)
		start
		;;

	stop)
		stop
		;;

	restart|reload)
		restart
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
	esac

exit $?
