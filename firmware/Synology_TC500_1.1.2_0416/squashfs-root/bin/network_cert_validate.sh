#!/bin/sh
PKI="ca_pem"
if [ "$#" -eq 1 ]; then
PEM=$1
elif [ "$#" -eq 2 ]; then
	if [ "$1" == "p12" ]; then
		PKI=$1
	fi
PEM=$2
fi

#if upload ca.pem and client.p12 ok
if [ "$1" == "set_time" ]; then
	PKI=$1
fi

#typedef enum {
#	CERT_VALID,
#	CERT_CERTIFICATE_FAIL,
#	CERT_PRIVATE_KEY_FAIL,
#	CERT_PRIVATE_KEY_NOT_MATCH,
#	CERT_FILE_IS_NOT_EXIST,
#} CERT_RESULT;

if [ ! $PEM ] ; then
	echo "error, no pem file input!"
	exit 4
fi

if [ ! -f $PEM ] ; then
	echo "error, cannot find pem file: $PEM"
	exit 4
fi

check_ca_pem()
{
	#pre-test private key
	openssl x509 -noout -pubkey -in $PEM  > /dev/null
	if [ $? != 0 ] ; then
		echo "error key"
		exit 2
	fi
}

check_p12()
{
	echo "$PEM"
	#pre-test private key
	#openssl pkcs12 -info -in $PEM -passin pass:whatever -nokeys > /dev/null
	#if [ $? != 0 ] ; then
	#	echo "error key"
	#	exit 2
	#fi
}

set_ca_datetime_to_system() {
	#Get ca.pem startdate
	startdate=$(openssl x509 -in "$PEM" -noout -startdate | cut -d "=" -f 2)
	#echo $startdate
	datetime_without_gmt=$(echo "$startdate" | sed 's/ GMT//')
	echo $datetime_without_gmt

	#Change datetime to UNIX timestamp
	timestamp=$(date -d "$datetime_without_gmt" +"%s")
	#echo $timestamp

	#Format timestamp for date command uesd
	formatted_date=$(date -d "@$timestamp" +"%Y-%m-%d %H:%M:%S")
	echo "$formatted_date"

	#Set datetime to system
	echo "set "$formatted_date" to system"
	date -u -s "$formatted_date"
}

if [ "$PKI" == "ca_pem" ]; then
	check_ca_pem
elif [ "$PKI" == "set_time" ]; then
	if [ -f "$PEM" ]; then
		if [ ! -f "/tmp/time_updated" ]; then
			set_ca_datetime_to_system
		fi
	fi
elif [ "$PKI" == "p12" ]; then
	check_p12
else
	echo "PKI:$PKI unknown"
	exit 1
fi

# don't change the message, systemd reads the message to check result.
echo "success"

exit 0
