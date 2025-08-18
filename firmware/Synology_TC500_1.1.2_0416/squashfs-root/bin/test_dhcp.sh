#!/bin/sh

DEF_IFACE="eth0"

if [ "$1" == "" ]; then
	IFACE=$DEF_IFACE
else
	IFACE=$1
fi

if [ "$IFACE" != "eth0" ] && [ "$IFACE" != "wlan0" ]; then
	echo "unknown interface"
	exit 2
fi

rm -f /tmp/test_dhcp_output
dhcpcd -LGT -4 -t 10 -f /etc/dhcpcd.conf $IFACE -c "/bin/test_dhcp_output.sh"

RET=$?
# the test_dhcp.cgi reads the output string.
if [ "$RET" == "0" ]; then
	echo "succeeded"
else
	echo "failed"
fi

return $RET
