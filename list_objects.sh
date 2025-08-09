#!/bin/bash

# One argument: camera name

# Lists all the targets for a given camera, and provides some stats: number of nights, total exposure

# Reading the global parameters:
source $(dirname "$0")/config.h

cd $ROOT_DIR >/dev/null

# Find all the cameras:
CAMERAS=$(find . -mindepth 1 -maxdepth 1 -type d|cut -d/ -f2|sort|uniq|grep -ivE "$EXCLUDE")
if test -z "$CAMERAS"
	then
	echo -e "\nNo cameras; exiting\n"
	exit
	fi
echo -e "\n *** All cameras ***"
echo "$CAMERAS"

# Find all the targets:
TARGETS=$(find . -mindepth 3 -maxdepth 3 -type d|cut -d/ -f4|sort|uniq|grep -ivE "$EXCLUDE")
if test -z "$TARGETS"
	then
	echo -e "\nNo targets; exiting\n"
	exit
	fi
echo -e "\n *** All targets ***"
echo "$TARGETS"

# Large loop over all the targets:
while read TARGET
	do
	echo -e "\n ======= $TARGET ======="

	# For given $target, find all the cameras:
	cameras_target=$(find . -mindepth 3 -maxdepth 3 -type d -iwholename \*\/"$TARGET"|cut -d/ -f2|sort|uniq|grep -ivE "$EXCLUDE")	
	if test -z "$cameras_target"
		then
		continue
		fi
	
	while read CAMERA
		do
		echo -e "   * Camera: $CAMERA *"		
		TOTAL_SUM=0
		# Loop over all sessions for given CAMERA and TARGET:
		for DIR in  "$CAMERA"/20*/"$TARGET"
			do
			DATE=$(echo "$DIR"|cut -d/ -f2)
			find "$CAMERA/$DATE/$TARGET/LIGHT/" -name 20\* > /tmp/list2
			NSHOTS=$(cat /tmp/list2| wc -l)
			EXPOSURE=$(head -n1 /tmp/list2 |rev|cut -b 12-|cut -d_ -f1|rev)
			TOTAL=$(echo $NSHOTS $EXPOSURE | awk '{printf $1*$2/3600}')
			TOTAL_SUM=$(echo $TOTAL_SUM $TOTAL|awk '{printf $1+$2}')
			echo "$CAMERA/$DATE/\"$TARGET\" : $NSHOTS shots ${EXPOSURE}s each; $TOTAL hours"
			done
		echo -e "Cumulative exposure = $TOTAL_SUM hours\n"
		done <<< "$cameras_target"

	# TARGETS loop
	done <<< "$TARGETS"

echo

cd - >/dev/null