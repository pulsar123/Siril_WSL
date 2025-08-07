#!/bin/bash

# One argument: camera name

# Lists all the targets for a given camera, and provides some stats: number of nights, total exposure

# Reading the global parameters:
source $(dirname "$0")/config.h

if test $# -ne 1
	then
	echo -e "\nOne argument: camera name"
	echo -e "\n Available camera names:\n"
	find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d|rev|cut -d/ -f1|rev|sort|grep -iv targets|grep -iv templates|grep -iv logs
	echo
	exit
	fi

CAMERA=$1

# Going to the root (camera) directory:
cd "$ROOT_DIR"/"$CAMERA"

find . -mindepth 2 -maxdepth 2 -type d|grep "^./2"|cut -d/ -f3|sort|grep -vi Bias|grep -vi FlatWizard|grep -vi snapshot|grep -vi process|sort|uniq >/tmp/list

while read TARGET
	do
	echo -e "\n*** Target $TARGET ***"
	TOTAL_SUM=0
	for DIR in  20*/"$TARGET"
		do
			DATE=$(echo "$DIR"|cut -d/ -f1)
			find $DATE/"$TARGET"/LIGHT/ -name 20\* > /tmp/list2
			NSHOTS=$(cat /tmp/list2| wc -l)
			EXPOSURE=$(head -n1 /tmp/list2 |rev|cut -b 12-|cut -d_ -f1|rev)
			TOTAL=$(echo $NSHOTS $EXPOSURE | awk '{printf $1*$2/3600}')
			TOTAL_SUM=$(echo $TOTAL_SUM $TOTAL|awk '{printf $1+$2}')
			
			# Finding the extension for light images:
#			LIGHT_EXT=$(/usr/bin/ls -1 $DATE/"$TARGET"/LIGHT/20*|head -n1|rev|cut -d. -f1|rev)#
			#NSHOTS=$( /usr/bin/ls -1 $DATE/"$TARGET"/LIGHT/20*.$LIGHT_EXT|wc -l)
#			ONE=$(/usr/bin/ls -1 $DATE/"$TARGET"/LIGHT/20*.$LIGHT_EXT|head -n1)
#			EXPOSURE=$(echo $ONE |rev|cut -b 12-|cut -d_ -f1|rev)
#			TOTAL=$(echo $NSHOTS $EXPOSURE | awk '{printf $1*$2/3600}')
#			TOTAL_SUM=$(echo $TOTAL_SUM $TOTAL|awk '{printf $1+$2}')
			echo "$CAMERA/$DATE/\"$TARGET\" : $NSHOTS shots ${EXPOSURE}s each; total exposure=$TOTAL hours"
		done
	echo "Cumulative exposure = $TOTAL_SUM hours"
	
	done < /tmp/list



echo
cd - >/dev/null