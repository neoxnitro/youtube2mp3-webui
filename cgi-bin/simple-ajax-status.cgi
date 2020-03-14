#!/bin/bash

echo "Content-type: text/html"
echo ""

if [ $REQUEST_METHOD == 'POST' ]; then
if [ "$CONTENT_LENGTH" -gt 0 ]; then
	read -n $CONTENT_LENGTH data <&0
fi
fi

POST=$data

if [ -z "$POST" ]; then
	echo "ERROR query is NULL !"
	exit 0
fi

 code=`echo "$POST" | sed -n 's/^.*code=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
 user=`echo "$POST" | sed -n 's/^.*user=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
 
 echo "<p>"
 
 if [ ! -f /tmp/youtube2mp3.$code ]; then
 
	if [ $user -eq 0 ];then
		echo "Hi \"Default\" user !"
	elif [ $user -eq 1 ];then
		echo "Hi Cocotte ;p"
	elif [ $user -eq 2 ];then
		echo "Hi Boss"
	fi
	echo "</br>"
	echo "</br>"
	
	echo "Thread status: ready"
 
 else
 <<hh
	cat /tmp/youtube2mp3.$code | while read line;
	do
		echo $(echo "$line" | sed -e "s/.*\r//g")
		echo "<br>"
	done
hh

#****** Allow read line if not finished by a \n ******

DONE=false
until $DONE ;do
read || DONE=true
	echo $(echo "$REPLY" | sed -e "s/.*\r//g")		# remove all before a \r
	echo "<br>"
done < /tmp/youtube2mp3.$code


fi

echo "</p>"