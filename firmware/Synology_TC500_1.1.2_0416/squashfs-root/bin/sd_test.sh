#!/bin/sh

function check_response() {
   result=$(echo $1 |grep "failed")
   if [[ "$result" != "" ]]
   then
	exit 1
   else
	echo -e "\033[0;31m$1\033[0m"
   fi
}
counter=0
random_num=0 #`od -vAn -N2 -tu2 < /dev/urandom`
echo $random_num
while [ 1 ] ;
let counter=counter+1
do
    #for i in 'action=status' 'action=list&dir=recording&list=dir' 'action=umount' 'action=mount'
    for i in 'action=umount' 'action=format' 'action=status' 'action=mount' 'action=status'
    do
        echo -e "\033[0;31m$i\033[0m"
        ret=`export RESPONSE_MODE=SKIP_HTTP_HEADERS;export REQUEST_METHOD="GET"; export QUERY_STRING="type=sdcard&$i";cd /www/cgi2/; ./storage.cgi`
        check_response $ret
    done
    if [ $random_num -ne 0 ]; then
	filecnt=`ls -l /mnt/SD0/ |awk -F" " '{print $2}'`
	if [ $? -eq 0 ]; then 
		[ $filecnt -ne 0 ] && exit 1 #format fail.
	else 
		exit 1
	fi
    fi

    random_num=`od -vAn -N2 -tu2 < /dev/urandom`
    random_num=`eval echo "$random_num"`
    dd if=/dev/zero of=/mnt/SD0/$random_num count=$random_num bs=10
    if [ $? -ne 0 ]; then #error, maybe read-only
    	exit 0
    fi
    sync
    ls -l /mnt/SD0/$random_num
    #echo $?
    sleep 2
    echo "test count:$counter"
done
exit 0
