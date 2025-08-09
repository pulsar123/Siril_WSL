#!/bin/bash
#
# Processing images from a single night (same camera and filter) session
#
# One argument - a path to the root session directory, e.g.
#   /cygdrive/i/NINA/SV705C/2025-07-22/"NGC 7331"
#

# Make sure siril-cli binary is on the $PATH
 if ! `which siril-cli.exe&>/dev/null`
	then
	echo "Error: siril-cli.exe is not on the $PATH !"
	exit 1
	fi
	
if test $# -ne 1
		then
		echo -e "\nShould have one argument: CAMERA/DATE/TARGET, e.g."
		echo -e "  SV705C/2025-07-22/\"NGC 7331\"\n"
		exit
		fi

# Reading the global parameters:
source $(dirname "$0")/config.h

cd "$ROOT_DIR/$1"
ROOT=`pwd`

# Detecting the per-camera master_bias file:
if test $(/usr/bin/ls -1 ../../master_bias_*.fit |head -n1)
  then 
	BIAS=$(basename $(/usr/bin/ls -1 ../../master_bias_*.fit |head -n1))
	echo "Found bias file: $BIAS"
  else 
	echo "No bias file in the root camera directory; exiting"
	exit 1
  fi


# Processing flats if needed:
if test ! -f ../pp_flat_stacked.$ext
then
echo "Creating the file pp_flat_stacked.$ext ..."
if test ! -d ../FlatWizard/FLAT
	then
	echo "No directory FlatWizard/FLAT; exiting"
	exit
	fi
cd ../FlatWizard/FLAT
cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >output.log <<EOF
requires $version
setext $ext
convert flat -out=../process
cd ../process
calibrate flat_ -bias=../../../$BIAS
stack pp_flat_ rej 3 3 -norm=mul
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
# Convert Light Frames to .$ext files
cd light
convert light -out=../process
cd ../process

# Pre-process Light Frames
calibrate light_ -bias=../../../$BIAS -flat=../../pp_flat_stacked -cfa -equalize_cfa -debayer

# Align lights
register pp_light_ $REGISTER_ARGS

# Stack calibrated lights to result.fit
stack r_pp_light_ rej 3 3 -norm=addscale -output_norm -out=../result
EOF

if test -f result.$ext
	then
	echo "Success!"
	else
	echo "Failed!"
	fi

echo
cd - >/dev/null
