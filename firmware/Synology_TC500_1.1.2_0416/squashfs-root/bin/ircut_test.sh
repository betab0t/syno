#!/bin/sh

RED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

showmsg() {
	echo -e "${CYAN}$1${NC}"
}

showmsgW() {
	echo -e "${YELLOW}$1${NC}"
}

showmsgE() {
	echo -e "${RED}$1${NC}"
}

touch /tmp/time_updated

showmsg "Start ircut test..."
showmsgW "Set night mode on"
diag action=update key=Sensor.LightSensor.NightMode strval=On
sleep 6

count=0
while true
do
	echo set 33 1 > /proc/gpio
	let count=count+1
	showmsgW "IR CUT on, count=$count"
	echo "count=$count" > /tmp/ircut_test_count
	sleep 6
	echo set 33 0 > /proc/gpio
	let count=count+1
	showmsgW "IR CUT off, count=$count"
	echo "count=$count" > /tmp/ircut_test_count
	cp /tmp/ircut_test_count /mnt/SD0/
	sync
	sleep 6
done
