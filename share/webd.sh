#!/bin/sh

/etc/init.d/S50_IPcamApp >/dev/null 2>&1 &
sleep 3
/etc/rc.d/rc1.d/S90webd stop
fuser -k 80/tcp
fuser -k 443/tcp

if [ "$1" = "gdb" ]; then
    QEMU_GDB=1234 webd /host/webd.conf
else
    webd /host/webd.conf
fi

