#!/bin/bash

# Youtube video to mp3 file convector


function print_color 
{
	echo "<b style=\"color:$1\">$2</b>"
}

function display_link
{
	echo "</br><a href=\"/mp3/$1\" download>$1</a></br>"
}

OUT=$(pwd)
ALTERNATIVEPATH=0

if [[ "$1" == *"update"* ]];then
	echo ""
	echo "********** DO YOU WAN UPDATE/INSTALL youtube-dl ? ***********"
	echo ""
	echo "Enter to continue: "
	read
	sudo rm /usr/bin/youtube-dl  # or apt-get remove -y youtube-dl
	sudo wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl
	sudo chmod a+x /usr/local/bin/youtube-dl
	hash -r
fi



USER="$3"
CODE=$4

if [ ! -z $2 ];then
	
	DIR="$2"
	DIRLAST="${DIR: -1}"
	if [[ ! $DIRLAST == "/" ]];then
		DIR="$DIR/"
	fi

	# Desintation path doesn't exist ... "downloads" path is used
	if [ ! -d "$DIR" ]; then
	  print_color "#9A0800" "WARN Destination path not exist: [$DIR]"
	  print_color "#9A0800" " ... Don't panic, your donwload will be done but the generate link at the  end of this page will not work ... i'm sad for you ;("
	  DIR="/home/odroid/Downloads/"
	  print_color "#08088A" "Alternative Path: [$DIR]"
	  ALTERNATIVEPATH=1
	  USER="."
	fi
	OUT="$DIR"
fi



if [ -z $4 ];then
	print_color "#9A0800" "ERROR missing code !"
	exit
fi

LINK="$1"

print_color "#08088A" "*****************************************************************"
print_color "#08088A" "* Link   : $LINK"
print_color "#08088A" "* Output : $OUT"
print_color "#08088A" "* code   : $CODE"
print_color "#08088A" "* User   : $USER"
print_color "#08088A" "*****************************************************************"

print_color "#08088A" "Request video information ..."

THUMBNAI="/tmp/$CODE"
rm -rf "/tmp/$CODE*"

youtube-dl --skip-download --write-thumbnail $LINK -o "$THUMBNAI" && mv "$THUMBNAI.webp" "$THUMBNAI.jpg" > /dev/null &						# background task

FILE_AND_EXTENSION=$(youtube-dl --skip-download --get-filename $LINK -o "%(title)s.%(ext)s")

if [ $? -ne 0 ];then
	print_color "#9A0800" "ERROR"
	exit 1
fi

FILE_NAME="${FILE_AND_EXTENSION%.*}"

echo "<b style=\"color:#08088A\">File name:</b> <b style=\"color:#009A08\">$FILE_NAME</b>"

#-- IF THUMBNAI --
#if [ -e "$THUMBNAI" ];then
	MYRAND=$(((RANDOM%100000)+1))
	echo "<img src='$THUMBNAI.jpg?$MYRAND' style='width:240px;height:180px'>"
#fi
#-- IF THUMBNAI --

print_color "#08088A" "Download and conversion ..."
youtube-dl -x --audio-format mp3 $LINK -o "%(title)s.%(ext)s"


if [ $? -ne 0 ];then
	print_color "#9A0800" ""
	print_color "#9A0800" "ERROR while converting"
	exit 1
else
	print_color "#08088A" "Conversion: Successful"
fi

# -- replace all "underscores" by "spaces" --
FULL_NAME_UNDERSCORE=$(echo "$FILE_NAME.mp3" | sed 's/_/ /g')
FULLNAME="$FILE_NAME.mp3" 
mv "$FULLNAME" "$FULL_NAME_UNDERSCORE"
FULLNAME="$FULL_NAME_UNDERSCORE"


# -- check if the file exist --
if [ ! -e "$FULLNAME" ];then
	print_color "#9A0800" "ERROR file doesn t exist !"
	print_color "#9A0800" "file: $FULLNAME"
	exit 1
fi 

#-- Add ID3TAG --
ARTIST=""
TITLE=""
	print_color "#08088A" "---------- ID3TAG ------------"
#-- determine artist name and title separator --
if [[ "$FILE_NAME" == *"-"* ]];then
	_ARTIST=$( echo "$FILE_NAME" | sed 's/-.*//'  | sed 's/_/ /g')											# recover Artist with "-"
	ARTIST="$(echo -e "${_ARTIST}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"	# remove start/end space
	print_color "#08088A" "Artist: $ARTIST"
	
	_TITLE=$( echo "$FILE_NAME" | sed 's/.*-//' | sed 's/_/ /g' ) 											# recover Title with "-"
	TITLE="$(echo -e "${_TITLE}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"		# remove start/end space
	print_color "#08088A" "Title : $TITLE"
elif [[ "$FILE_NAME" == *"~"* ]];then
	_ARTIST=$( echo "$FILE_NAME" | sed 's/~.*//'  | sed 's/_/ /g')											# recover Artist with "-"
	ARTIST="$(echo -e "${_ARTIST}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"	# remove start/end space
	print_color "#08088A" "Artist: $ARTIST"
	
	_TITLE=$( echo "$FILE_NAME" | sed 's/.*~//' | sed 's/_/ /g' ) 											# recover Title with "-"
	TITLE="$(echo -e "${_TITLE}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"		# remove start/end space
	print_color "#08088A" "Title : $TITLE"
else
	if [[ "$FILE_NAME" == *" "* ]];then
		ARTIST=$( echo "$FILE_NAME" | awk '{print $1,$2}')																		# print the first two columns
		TITLE=$( echo "$FILE_NAME" | awk '{for(i=3;i<NF;i++)printf "%s",$i OFS; if (NF) printf "%s",$NF; printf ORS}')			# print the rest of columns
		print_color "#08088A" "Artist: $ARTIST"
		print_color "#08088A" "Title : $TITLE"
	else
		echo "<center>"
		print_color "#9A0800" "I'm not enough brilliant to determine the 'Artist name', I'm sorry"
		print_color "#9A0800" "I hope so, you will forgive me ?"
		echo "</center>"
		print_color "#08088A" "Title : $TITLE"
		TITLE="$FILE_NAME"
	fi
fi	

# id3v2 -a  -t "$TITLE" "$FULLNAME"												# Add ID3TAG v2 on the local file	
#-- Add image to mp3 file --


#-- Add INFO+image to mp3 file --
if [ -e "$THUMBNAI.jpg" ];then	# is tumbnail image exist
	#print_color "#08088A" "Set info+cover image: ..."		
	eyeD3 --to-v2.3 --add-image "$THUMBNAI.jpg":OTHER --artist "$ARTIST" --title "$TITLE" "$FULLNAME" > /dev/null
	if [ $? -eq 0 ];then
		print_color "#007027" "Set ID3TAG+image cover : OK"	
	else
		print_color "#af0000" "Set ID3TAG+image cover : ERROR"	
               print_color "#af0000" "eyeD3 --to-v2.3 --add-image \"$THUMBNAI.jpg\":OTHER --artist \"$ARTIST\" --title \"$TITLE\" \"$FULLNAME"
	fi
else		
	#print_color "#08088A" "Set info: ..."	
	eyeD3 --to-v2.3 --artist "$ARTIST" --title "$TITLE" "$FULLNAME" > /dev/null
	if [ $? -eq 0 ];then
		print_color "#007027" "Set ID3TAG : OK"	
	else
		print_color "#af0000" "Set ID3TAG : ERROR"	
	fi
fi

print_color "#08088A" "------------------------------"


local_size=$(stat -c %s "$FULLNAME")
remote_size=$(stat -c %s "$OUT$FULLNAME")

if echo $local_size | egrep -q '^[0-9]+$'; then
   if [ $local_size -eq $remote_size ];then
		print_color "#009A08" "The local file is already present remotely"
		rm "$FULLNAME"
		if [ $ALTERNATIVEPATH -eq 0 ];then
			display_link "$USER/$FULLNAME"
		else
			print_color "#9A0800" "No generated link like expected"
		fi
		exit 0
	else
		print_color "#08088A" "Move the file [$FULLNAME] to [$OUT]"
		cp "$FULLNAME" /home/odroid
		cp "$FULLNAME" "$OUT"
		print_color "#08088A" "copy result: $?"
   fi	   
fi

sleep 0.1

remote_size=$(stat -c %s "$OUT$FULLNAME")

if echo $remote_size | egrep -q '^[0-9]+$'; then
   if [ $local_size -eq $remote_size ];then
		print_color "#009A08" "Copy: Successful"
		rm "$FULLNAME"
		if [ $ALTERNATIVEPATH -eq 0 ];then
			display_link "$USER/$FULLNAME"
		else
			print_color "#9A0800" "No generated link like expected"
		fi
	else
		print_color "#9A0800" "ERROR while copying ..."
		exit 1
   fi	
else
	print_color "#9A0800" "ERROR, remote_size: $remote_size"
	exit 1
fi




exit 0
