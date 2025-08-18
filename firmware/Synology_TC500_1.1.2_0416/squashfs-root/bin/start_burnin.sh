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

showmsgW "Start burnin test..."
sleep 5
if [ ! -f /data/app/burnin_test_nas_ip ]; then
	showmsgE "can not find file: /data/app/burnin_test_nas_ip!"
	exit 0
fi

MID=`product_printenv MODEL|cut -d = -f 2`
SERIAL=`product_printenv SERIAL|cut -d = -f 2`
NAS_IP=`cat /data/app/burnin_test_nas_ip`

echo "$MID"
echo "$SERIAL"
echo "$NAS_IP"

if [ "$NAS_IP" == "" ]; then
	rm -f /data/app/burnin_test_nas_ip
	sync
	exit 1
fi

# connect to net disk
diag action=update json='{"Recorder": {"1": {"StorageType": "CIFS"}}, "ByPassMode": 1}'
diag action=update json='{"Storage": {"1": {"NetDiskInfo": {"Hostname": '"\"$NAS_IP\""', "Username": "burnin_test", "Password": "edx12345", "ShareFolderPath": "SynologyBurnInTest"}}}, "ByPassMode": 1}'

showmsgW "wait mount cifs ready..."

count=0
retry=100
while true
do
	let count=count+1
	CIFS_READY=`diag action=list key=Storage.1.Status`
	if [ "$CIFS_READY" == "ACTIVE" ]; then
		showmsgW "mount cifs is ready, then get the burnin script in NAS"
		if [ -f /mnt/smb/BurnInTestScript/$MID/burn_in_script_nas.sh ]; then
			showmsgW "burn_in_script_nas.sh is ready !"
			cp /mnt/smb/BurnInTestScript/$MID/burn_in_script_nas.sh /tmp/
			/tmp/burn_in_script_nas.sh &
			exit 0
		fi
	fi
	if [ "$count" -gt "$retry" ]; then
		showmsgW "retry timeout..."
		exit 0
	fi
	echo "retry $count/$retry..."
	sleep 1
done
