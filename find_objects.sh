#!/bin/bash

# One argument: camera name

# Finds all the targets for a given camera, and provides some stats: number of nights, total exposure

if test $# -ne 1
	then
	echo "One argument: camera name"
	exit
	fi

CAMERA=$1

# Reading the global parameters:
source $(dirname "$0")/config.h

# Going to the root (camera) directory:
cd "$ROOT_DIR"/"$CAMERA"

find . -mindepth 2 -maxdepth 2 -type d|grep "^./2"|cut -d/ -f3|sort|grep -vi Bias|grep -vi FlatWizard|grep -vi snapshot|grep -vi process|sort|uniq >~/tmp/list

while read TARGET
	do
	echo -e "\n*** Target $TARGET ***"
	TOTAL_SUM=0
	for DIR in  20*/"$TARGET"
		do
			DATE=$(echo "$DIR"|cut -d/ -f1)
			NSHOTS=$( /usr/bin/ls -1 $DATE/"$TARGET"/LIGHT/20*.$ext|wc -l)
			ONE=$(/usr/bin/ls -1 $DATE/"$TARGET"/LIGHT/20*.$ext|head -n1)
			EXPOSURE=$(echo $ONE |rev|cut -b 12-|cut -d_ -f1|rev)
			TOTAL=$(echo $NSHOTS $EXPOSURE | awk '{printf $1*$2/3600}')
			TOTAL_SUM=$(echo $TOTAL_SUM $TOTAL|awk '{printf $1+$2}')
			echo "$DATE: $NSHOTS shots ${EXPOSURE}s each; total exposure=$TOTAL hours"
		done
	echo "Cumulative exposure = $TOTAL_SUM hours"
	
	done < ~/tmp/list



echo
cd - >/dev/null