#!/bin/sh

CERT_FILE_PATH=/data/app/webd
#DOMAIN_NAME='diag action=list key=Property.Product.Brand'
CERT_KEY=$CERT_FILE_PATH/https.key
CERT_CSR=$CERT_FILE_PATH/https.csr
CERT_CRT=$CERT_FILE_PATH/https.crt
CERT_PEM=$CERT_FILE_PATH/https.pem
ROOT_CA_KEY=$CERT_FILE_PATH/rootCA.key
ROOT_CA_CRT=$CERT_FILE_PATH/rootCA.crt
LOCK=/tmp/doing_selfsign
RED='\033[0;31m'
NC='\033[0m' # No Color
PKI="ecc"

remove_lock()
{
    rm -rf "$LOCK"
}
another_instance()
{
    echo "There is another instance running, exiting" |logger -s
    exit 1
}

self_gen_ecc()
{
	#Create Root Key. 
	openssl ecparam -name prime256v1 -genkey -noout -out $ROOT_CA_KEY 2>&1 |logger -s
	sync
	#Create and self sign the Root Certificate
	openssl req -x509 -new -key $ROOT_CA_KEY -out $ROOT_CA_CRT -sha256 -days 36500 -subj "/C=TW/O=$BRAND/CN=$BRAND" 2>&1 |logger -s
	sync

	#Create the certificate key
	openssl ecparam -name prime256v1 -genkey -noout -out $CERT_KEY 2>&1 |logger -s
	sync
}

self_gen_rsa()
{
	echo "openssl genrsa -out $ROOT_CA_KEY 2048"
	#Create Root Key. 4096 take too much time 
	openssl genrsa -out $ROOT_CA_KEY 2048 2>&1 |logger -s
	sync
	#Create and self sign the Root Certificate
	#Fixs IE's warning DLG_FLAGS_INVALID_CA that import this rootCA certificate to IE 
	openssl req -x509 -new -nodes -key $ROOT_CA_KEY -subj "/C=TW/O=$BRAND/CN=$BRAND" -sha256 -days 36500 -out $ROOT_CA_CRT 2>&1 |logger -s
	sync
	#Create the certificate key
	openssl genrsa -out $CERT_KEY 2048 2>&1 |logger -s
	sync
}


if [ "$1" == "delete" ]; then
	rm -f $CERT_PEM $CERT_KEY $CERT_CRT
	diag action=update key=Network.HTTPS.CertificateAvailable boolval=false
	exit 0;
elif [ "$1" == "rsa" ]; then
	PKI=$1
fi

echo -e "${RED}Generate PKI type: $PKI${NC}"

mkdir "$LOCK" || another_instance
trap remove_lock EXIT

#export MAC=`diag action=list key=Network.0.MACAddress | sed -e 's/://g'`
#echo -e "${RED}MAC: $MAC${NC}"
export BRAND=`diag action=list key=Property.Product.Brand`
echo -e "${RED}BRAND: $BRAND${NC}"
#export MODEL=`diag action=list key=Property.Product.Model`
#echo -e "${RED}MODEL: $MODEL${NC}"
#export IP=`diag action=list key=Network.0.DHCP.IPAddress`
#echo -e "${RED}IP: $IP${NC}"
export HOST=`diag action=list key=Generic.Information.HostName`
echo -e "${RED}HOST: $HOST${NC}"

export OPENSSL_CONF=/etc/openssl.cnf #fix WARNING: can't open config file: /home/abbehuang/project/vs8/repo/source/..//source/out/ssl/openssl.cnf
export RANDFILE=/tmp/.rnd #fix unable to write 'random state'

#Create folder
[ -f $CERT_FILE_PATH ] && rm $CERT_FILE_PATH
[  -d $CERT_FILE_PATH ] && rm -rf $CERT_FILE_PATH
mkdir -p $CERT_FILE_PATH
logger -s "$0"

if [ "$PKI" == "ecc" ]; then
	self_gen_ecc
elif [ "$PKI" == "rsa" ]; then
	self_gen_rsa
fi

#Create the signing (csr)
openssl req -new -sha256 -key $CERT_KEY -subj "/C=TW/O=$BRAND/CN=$HOST" -out $CERT_CSR 2>&1 |logger -s
sync
#Generate the certificate
openssl x509 -req -in $CERT_CSR -CA $ROOT_CA_CRT -CAkey $ROOT_CA_KEY -CAcreateserial -extensions default_cert_ext -extfile $OPENSSL_CONF -out $CERT_CRT -days 36500 -sha256 2>&1 |logger -s
sync
[ -f $CERT_KEY ] || logger -s "no $CERT_KEY"
[ -f $CERT_CRT ] || logger -s "no $CERT_CRT"
cat $CERT_KEY $CERT_CRT > $CERT_PEM
sync
[ ! -f $CERT_PEM ] && logger -s "create $CERT_PEM file failed"

#/bin/https_cert_validate.sh $PKI $CERT_PEM 2>&1 |logger -s
ls -l $CERT_FILE_PATH | logger -s

diag action=update key=Network.HTTPS.CertificateAvailable boolval=true
