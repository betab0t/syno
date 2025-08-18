#!/bin/sh
OUT=/tmp/test_dhcp_output

rm -f $OUT
echo "new_ip_address=$new_ip_address" >> $OUT
echo "new_subnet_mask=$new_subnet_mask" >> $OUT
echo "new_routers=$new_routers" >> $OUT
