#!/bin/bash

# One argument: camera name

# Lists all the targets for a given camera, and provides some stats: number of nights, total exposure

list_sessions() {

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

}


# Reading the global parameters:
source $(dirname "$0")/config.h

cd $ROOT_DIR >/dev/null
# Find all the cameras:
CAMERAS=$(find . -mindepth 1 -maxdepth 1 -type d|cut -d/ -f2|sort|uniq|grep -ivE "$EXCLUDE")
if test -z "$CAMERAS"
	then
	echo -e "\nNo cameras; exiting\n"
	cd - >/dev/null
	exit
	fi
# Find all the targets:
TARGETS=$(find . -mindepth 3 -maxdepth 3 -type d|cut -d/ -f4|sort|uniq|grep -ivE "$EXCLUDE")
if test -z "$TARGETS"
	then
	echo -e "\nNo targets; exiting\n"
	cd - >/dev/null
	exit
	fi


if test $# -eq 0
then
echo -e "\n *** All cameras ***"
echo "$CAMERAS"

echo -e "\n *** All targets ***"
echo "$TARGETS"

echo -e "\n\nUse the following optional arguments for a detailed listing:\n"
echo -e " -a \t\t: List details for all target/camera combinations"
echo -e " -c CAMERA \t: List details for a specific camera CAMERA"
echo -e " -t TARGET \t: List details for a specific target TARGET"
echo
cd - >/dev/null
exit
	

elif test $# -eq 2 -a $1 = '-c'
then
CAMERA="$2"
echo -e "\n Listing for camera $CAMERA\n"
# For given CAMERA, find all targets:
TARGETS=$(find $CAMERA -mindepth 3 -maxdepth 3 -type d 2>/dev/null |cut -d/ -f3|sort|uniq|grep -ivE "$EXCLUDE" )
	if test -z "$TARGETS"
		then
		echo -e "No such camera: $CAMERA; exiting\n"
		cd - >/dev/null
		exit 1
		fi

while read TARGET
	do
	echo -e "\n ======= $TARGET ======="
	list_sessions
	done <<< "$TARGETS"


elif test $# -eq 2 -a $1 = '-t'
then
TARGET="$2"
echo -e "\n Listing for target $TARGET\n"
# For a given TARGET, find all cameras:
	# For given $target, find all the cameras:
	cameras_target=$(find . -mindepth 3 -maxdepth 3 -type d -iwholename \*\/"$TARGET"|cut -d/ -f2|sort|uniq|grep -ivE "$EXCLUDE")	
	if test -z "$cameras_target"
		then
		echo -e "No such target: $TARGET; exiting\n"
		cd - >/dev/null
		exit 1
		fi
	
	while read CAMERA
		do
		echo -e "   * Camera: $CAMERA *"		
		list_sessions
		done <<< "$cameras_target"

	
	
elif test $# -eq 1 -a $1 = '-a'
then
# List all cameras and targets:
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
		list_sessions
		done <<< "$cameras_target"

	# TARGETS loop
	done <<< "$TARGETS"


else
echo -e "\nWrong argmument!\n"
cd - >/dev/null
exit 1
fi


echo

cd - >/dev/null