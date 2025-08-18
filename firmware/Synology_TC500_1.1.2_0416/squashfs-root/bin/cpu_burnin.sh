#!/bin/sh

echo "start cpu burn-in ..."
while true
do
	nice -n 15 openssl speed -evp aes-128-cbc > /dev/null 2>&1
done
