#!/bin/bash
#
# Processing images from a single night (same camera and filter) session
#

if test $# -ne 1
		then
		echo "Should have one argument: camera/date/target, e.g."
		echo "  SV705C/2025-07-22/\"NGC 7331\""
		exit
		fi

# Reading the global parameters:
source $(dirname "$0")/config.h

cd "$ROOT_DIR/$1"
ROOT=`pwd`

source $(dirname "$0")/bias_flat.sh

rm -f result.$ext

echo -e "\nProcessing lights..."
cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >output.log <<EOF
requires $version
setext $ext
# Convert Light Frames to .$ext files
cd light
convert light -out=../process
cd ../process

# Pre-process Light Frames
calibrate light_ $BIAS_ARGUMENT $FLAT_ARGUMENT $BPM_ARGUMENT -cfa -equalize_cfa -debayer

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
