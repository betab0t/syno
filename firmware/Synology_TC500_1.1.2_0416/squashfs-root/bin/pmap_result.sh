#!/bin/sh
ipcs -m
printf " %-17s %-s\n" PROC PSS\(KB\)
echo -e "---------------------------"
for i in 'systemd' 'nvtd' 'mediad' 'streamd' 'webd' 'recorder' 'inetd' 'zcip' 'dhcpcd' 'ntpdaemon' 'ntpd' 'syslogd' 'central_server' 'telnetd'
do 
	pss=`pmap -x $(pidof $i) |grep total |awk -F" " '{print $3}'`
#	echo -e "\033[0;31m$i\033[0m  \tPSS:$pss"
	printf " %-15s %6d\n" $i $pss
	let tt=tt+$pss
done
echo -e "---------------------------"
echo -e "Total: \t\t  $tt KB"
exit 0
