#!/bin/sh

stop() {
	if [ -d /data/app/etc/rc.d/rc1.d ]; then
		for initscript in /data/app/etc/rc.d/rc1.d/K[0-9][0-9]*
		do
			if [ -x $initscript ] ; then
				echo "[stop]: $initscript"
				$initscript stop
			fi
		done
	else
		for initscript in /etc/rc.d/rc1.d/K[0-9][0-9]*
		do
			if [ -x $initscript ] ; then
				echo "[stop]: $initscript"
				$initscript stop
			fi
		done
	fi
}

echo "Stop Daemon Service..."
stop
sleep 5
echo "Stop Daemon Service...ok"
