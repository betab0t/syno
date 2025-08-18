#!/bin/sh

CYAN='\033[1;36m'
NC='\033[0m'

showmsg() {
	echo -e "${CYAN}$1${NC}"
}

target_boot=`uboot_printenv target_boot`
if [ "${target_boot}" == "target_boot=1" ]; then

showmsg "post-script: set target_boot to 0"
uboot_setenv target_boot 0
else

showmsg "post-script: set target_boot to 1"
uboot_setenv target_boot 1
fi

# change board_id to 0
board_id=`product_printenv board_id | cut -d = -f 2`
if [ "${board_id}" != "0" ]; then
	showmsg "post-script: board_id=$board_id, set board_id to 0"
	product_setenv board_id 0
fi

# remove the viewer account if it exists
user_cnt=`diag action=list key=Generic.User.Count`
if [ "${user_cnt}" == "2" ]; then
	diag action=update key=Generic.User.MinCount intval=1
	diag action=update json='{"actions": [{"action": "remove", "key": "Generic.User", "index": [1]}]}'
	sleep 1
	sync
fi

ntp_server_1=`diag action=list key=Generic.Time.NTP.Server1`
if [ -n "${ntp_server_1}" ]; then
	diag action=update key=Generic.Time.NTP.Server1 strval=""
	sleep 1
	sync
fi

rm /tmp/fwupgrade_test
free
