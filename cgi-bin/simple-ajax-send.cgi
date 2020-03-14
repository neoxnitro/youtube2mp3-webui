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

 XX=`echo "$POST" | sed -n 's/^.*w=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
 code=`echo "$POST" | sed -n 's/^.*code=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
 user=`echo "$POST" | sed -n 's/^.*user=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
 
 # replace special URI code
 XX=$(echo $XX | sed 's/%253A/:/g')
 XX=$(echo $XX | sed 's/%252F/\//g')
 XX=$(echo $XX | sed 's/%253F/?/g')
 XX=$(echo $XX | sed 's/%253D/=/g')
 
 echo "Youtube link: $XX"
 pushd .
 
 mkdir /tmp/$code
 cd /tmp/$code

#	if [ $user -eq 1 ];then			# marie
#		/home/cgi/youtube2mp3.sh $XX /media/16G/MP3/Marie/ Marie $code > /tmp/youtube2mp3.$code
#	elif [ $user -eq 2 ];then		# fabrice
#		/home/cgi/youtube2mp3.sh $XX /media/16G/MP3/Fab/ Fab $code > /tmp/youtube2mp3.$code
#	else
		/home/cgi/youtube2mp3.sh $XX /home/odroid/download_64G . $code > /tmp/youtube2mp3.$code
#	fi
 
 rm -rf /tmp/$code

 popd
 

 
 
