#!/bin/bash
#
# Processing images from a single night (same camera and filter) session
#

if test $# -ne 1
		then
		echo "Should have one argument: camera/date/target, e.g."
		echo "  SV705Cn/2025-07-22/\"NGC 7331\""
		exit
		fi

# Reading the global parameters:
source $(dirname "$0")/config.h

cd "ROOT_DIR/$1"
ROOT=`pwd`

source $(dirname "$0")/bias_flat.sh

echo -e "\nProcessing lights..."

cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >output.log <<EOF
requires $version
setext $ext

# Convert Light Frames to .fit files
cd light
convert light -out=../process
cd ../process

# Calibrate Light Frames
calibrate light_ -bias=../../../$BIAS -flat=../../pp_flat_stacked -cfa -equalize_cfa

# Extract Ha and OIII
seqextract_HaOIII pp_light_ -resample=oiii

# Align Ha lights
register Ha_pp_light_ $REGISTER_ARGS

# Stack calibrated Ha lights to Ha_stack (temporary)
stack r_Ha_pp_light_ rej 3 3 -norm=addscale -output_norm -32b -out=results_00001

# and flip if required
mirrorx_single results_00001

# Align OIII lights
register OIII_pp_light_ $REGISTER_ARGS

# Stack calibrated OIII lights to OIII_stack (temporary)
stack r_OIII_pp_light_ rej 3 3 -norm=addscale -output_norm -32b -out=results_00002

# and flip if required
mirrorx_single results_00002

# Align the result images, small shifts and chromatic aberrations can occur
register results_ -transf=shift -interp=none $REGISTER_ARGS

# Renorm OIII to Ha using PixelMath
pm \$r_results_00002\$*mad(\$r_results_00001\$)/mad(\$r_results_00002\$)-mad(\$r_results_00001\$)/mad(\$r_results_00002\$)*median(\$r_results_00002\$)+median(\$r_results_00001\$)
save ../result_OIII

# Save Ha final result
load r_results_00001
save ../result_Ha
EOF

if test -f result_Ha.$ext -a -f result_OIII.$ext
	then
	echo "Success!"
	else
	echo "Failed!"
	fi

echo
cd - >/dev/null
