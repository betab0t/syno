#!/bin/sh
PKI="ecc"
if [ "$#" -eq 1 ]; then
PEM=$1
elif [ "$#" -eq 2 ]; then
	if [ "$1" == "rsa" ]; then
		PKI=$1
	fi
PEM=$2
fi

#typedef enum {
#    CERT_VALID,
#    CERT_CERTIFICATE_FAIL,
#    CERT_PRIVATE_KEY_FAIL,
#    CERT_PRIVATE_KEY_NOT_MATCH,
#    CERT_FILE_IS_NOT_EXIST,
#} CERT_RESULT;

if [ ! $PEM ] ; then
	echo "error, no pem file input!"
	exit 4
fi

if [ ! -f $PEM ] ; then
	echo "error, cannot find pem file: $PEM"
	exit 4
fi

check_ecc()
{
	#openssl pkey -pubout -in $PEM > /dev/null
	openssl ec -pubout -in $PEM > /dev/null
	#pre-test certificate
	if [ $? != 0 ] ; then
		echo "error certificate"
		exit 1
	fi
	#CERT_MD5=`openssl pkey -pubout -in $PEM | openssl md5`
	CERT_MD5=`openssl ec -pubout -in $PEM |openssl md5`
	#echo "CERT_MD5" $CERT_MD5
	
	#pre-test private key
	openssl x509 -noout -pubkey -in $PEM  > /dev/null
	if [ $? != 0 ] ; then
		echo "error key"
		exit 2
	fi
	PKEY_MD5=`openssl x509 -noout -pubkey -in $PEM | openssl md5`
	#echo "PKEY_MD5" $PKEY_MD5
	
	if [ "$CERT_MD5" != "$PKEY_MD5" ] ; then
		echo "error, PEM's PKey and certificate doesn't match"
		exit 3
	fi
}

check_rsa()
{
	#pre-test certificate
	openssl x509 -noout -modulus -in $PEM  > /dev/null
	if [ $? != 0 ] ; then
		echo "error certificate"
		exit 1
	fi
	CERT_MD5=`openssl x509 -noout -modulus -in $PEM | openssl md5`
	#echo "CERT_MD5" $CERT_MD5
	
	#pre-test private key
	openssl rsa -noout -modulus -in $PEM  > /dev/null
	if [ $? != 0 ] ; then
		echo "error key"
		exit 2
	fi
	PKEY_MD5=`openssl rsa -noout -modulus -in $PEM | openssl md5`
	#echo "PKEY_MD5" $PKEY_MD5
	
	if [ "$CERT_MD5" != "$PKEY_MD5" ] ; then
		echo "error, PEM's PKey and certificate doesn't match"
		exit 3
	fi
}

if [ "$PKI" == "ecc" ]; then
	check_ecc
elif [ "$PKI" == "rsa" ]; then
	check_rsa
else
	echo "PKI:$PKI unknown"
	exit 1
fi

# don't change the message, systemd reads the message to check result.
echo "success"

exit 0
