#!/bin/bash
#
# Processing images from more than one night (same camera and filter)
#
# 


# Make sure siril-cli binary is on the $PATH
 if ! `which siril-cli&>/dev/null`
	then
	echo "Error: siril-cli is not on the $PATH !"
	exit 1
	fi
	
if test $# -lt 2
		then
		echo -e "\n Syntax:\n"
		echo " $(basename $0)  [-n]  CAMERA  TARGET"
		echo -e "\n Here:"
		echo -e "\tCAMERA \t- camera name (e.g. SV905C)"
		echo -e "\tTARGET \t- target name (e.g. \"NGC 7331\")"
		echo -e "\t-n \t- an optional argument, to process both"
		echo -e "\t\t the broadband and narrowband (with the camera"
		echo -e "\t\t name having a trailing \"n\") sessions"
		exit
		fi

BOTH=0
if test "$1" = "-n"
	then
	BOTH=1
	echo -e "\n Combining broad and narrow band sessions.\n"
	shift
	fi

CAMERA="$1"
TARGET="$2"

# Reading the global parameters:
source $(dirname "$0")/config.h

# Going to the root (camera) directory:
cd "$ROOT_DIR"/"$CAMERA"

# Creating the sessions list:
if test $BOTH -eq 0
	then
	/usr/bin/ls -1d */"$TARGET" > /tmp/sessions.lst
	else
	/usr/bin/ls -1d ../${CAMERA}*/*/"$TARGET" > /tmp/sessions.lst
	fi

N_nights=$(cat /tmp/sessions.lst |wc -l)
if test $N_nights -eq 0
	then
	echo "No sessions found for $CAMERA and $TARGET; exiting"
	exit 1
	fi

echo "Found $N_nights sessions:"
cat /tmp/sessions.lst

# Absolute path to the destination process folder:
DEST=$(pwd)/"$TARGET"/process
rm -Rf "$DEST" &>/dev/null
mkdir -p "$DEST" &>/dev/null

i=0
# Large cycle over the multiple nights
while read DIR
	do
	DATE=$(echo "$DIR" |cut -d/ -f1)
	cd "$DIR"
	echo -e "\n*** Processing $DIR ***\n"

	# Detecting the per-camera master_bias file:
	if test $(/usr/bin/ls -1 ../../master_bias_*.fit |head -n1)
	then 
		BIAS=$(basename $(/usr/bin/ls -1 ../../master_bias_*.fit |head -n1))
		echo "Found bias file: $BIAS"
	else 
		echo "No bias file in the root camera directory; exiting"
		exit 1
	fi

	# Cleaning up old process files
	rm -Rf process &>/dev/null
	mkdir -p process &>/dev/null
		
	# Processing flats if needed:
	if ! test -f ../pp_flat_stacked.$ext
		then
			echo "Creating the file pp_flat_stacked.$ext ..."
			if ! test -d ../FlatWizard/FLAT
				then
					echo "No directory FlatWizard/FLAT; exiting"
					exit 1
				fi
			cd ../FlatWizard/FLAT
			cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >../output.log <<EOF
requires $version
setext $ext
convert flat -out=../process
cd ../process
calibrate flat_ -bias=../../../$BIAS
stack pp_flat_ rej 3 3 -norm=mul
close
EOF
			if test ! -f ../process/pp_flat_stacked.$ext
				then
					echo "Failed to create file pp_flat_stacked.$ext; exiting"
					exit 1
				fi
			mv ../process/pp_flat_stacked.$ext ../..
			rm -Rf ../process
			cd "$ROOT" >/dev/null
		else
			echo "Found master flat file pp_flat_stacked.$ext"
		fi


echo "Processing lights..."
cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >output.log <<EOF
requires $version
setext $ext
# Convert Light Frames to .fit files
cd light
convert light -out=../process
cd ../process

# Pre-process Light Frames
calibrate light_ -bias=../../../$BIAS -flat=../../pp_flat_stacked -cfa -equalize_cfa -debayer
close
EOF

	for name in process/pp_light_*.$ext
		do
		i=$(($i + 1))
		mv $name "$DEST"/pp_light_$(printf "%05d" $i).$ext
		done


	cd ../..
	# End of the loop:
	done < /tmp/sessions.lst


if test $BOTH -eq 0
	then
	RESULT=result
	else
	RESULT=result_both
	fi

echo -e "\n*** Processing all nights ***\n"
cd "$DEST"
cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >../output.log <<EOF
requires $version
setext $ext
# Align lights
register pp_light_ $REGISTER_ARGS

# Stack calibrated lights to result.fit
stack r_pp_light_ rej 3 3 -norm=addscale -output_norm -out=../$RESULT
close
EOF

cd ..
echo
if test -f $RESULT.$ext
	then
	echo "Success!"
	else
	echo "Failed!"
	fi

cd - >/dev/null
