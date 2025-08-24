#!/bin/bash

# This script is only to be called from inside other scripts
# Its purpose is to find all the required master bias and flat files
# It initializes the values for $BIAS_FLAT and $BIAS, and builds 
# pp_flat_stacked.$ext file if it's missing

# Unsetting all the variables which might be set here:
unset NO_FLAT NO_BIAS_FLAT NO_BIAS BIAS BIAS_FLAT FLAT_ARGUMENT BIAS_FLAT_ARGUMENT BIAS_ARGUMENT BAD_PIXELS BPM_ARGUMENT ISO_FLAT ISO_LIGHT

echo

name=$(/usr/bin/ls -1 LIGHT/20* 2>/dev/null|head -n1)
if test ! $name
	then
	echo -e "No lights; skipping\n"
	# Checking if this happened inside a multy-night script:
	if test "$DIR"
		then
			cd ../..
		fi
	continue
	fi
file_ext=$(echo $name|rev|cut -d. -f1|rev)

name_flat=$(/usr/bin/ls -1 ../FlatWizard/FLAT/20* 2>/dev/null|head -n1)
if test ! $name_flat
	then
		echo -e "Missing flats; will calibrate without flats"
		NO_FLAT=1
		NO_BIAS_FLAT=1
	fi


# For cr2 files only, getting the ISO value for flats and lights:
if test $file_ext = "cr2" -o $file_ext = "CR2"
	then
	ISO_LIGHT=$(exiftool $name|grep "Base ISO"|cut -d: -f2|cut -d" " -f2)
	BIAS=master_bias_ISO${ISO_LIGHT}.$ext
	if test ! -f ../../$BIAS
		then
		echo -e "Missing the bias file for lights: $BIAS"
		NO_BIAS=1
		fi

	if test ! $NO_FLAT
		then
			ISO_FLAT=$(exiftool $name_flat|grep "Base ISO"|cut -d: -f2|cut -d" " -f2)
			BIAS_FLAT=master_bias_ISO${ISO_FLAT}.$ext
			if test ! -f ../../$BIAS_FLAT
				then
					echo -e "Missing the bias file for flats: $BIAS_FLAT"
					NO_BIAS_FLAT=1
				fi
		fi
		
	else
		if test $(/usr/bin/ls -1 ../../master_bias_*.$ext 2>/dev/null |head -n1)
			then 
				BIAS_FLAT=$(basename $(/usr/bin/ls -1 ../../master_bias_*.$ext |head -n1))
				BIAS=$BIAS_FLAT
			else 
				echo -e "No bias file in the root camera directory; calibration will not use bias"
				NO_BIAS=1
				NO_BIAS_FLAT=1
			fi	
	fi


if test ! $NO_FLAT
	then
		FLAT_ARGUMENT=" -flat=../../pp_flat_stacked "
	fi

if test ! $NO_BIAS_FLAT
	then
		echo -e "Found bias for flats: $BIAS_FLAT"
		BIAS_FLAT_ARGUMENT=" -bias=../../../$BIAS_FLAT "
	fi

if test ! $NO_BIAS
	then
		echo -e "Found bias for lights: $BIAS"
		BIAS_ARGUMENT=" -bias=../../../$BIAS "
	fi
	
	
# Processing flats if needed:
if test ! $NO_FLAT
	then
		if test ! -f ../pp_flat_stacked.$ext
		then
		echo "Creating the file pp_flat_stacked.$ext ..."
		cd ../FlatWizard/FLAT
cmd.exe /c 'C:\Program Files\SiriL\bin\siril-cli.exe' -s - -d . >output.log <<EOF
requires $version
setext $ext
convert flat -out=../process
cd ../process
calibrate flat_ $BIAS_FLAT_ARGUMENT
stack pp_flat_ rej 3 3 -norm=mul
EOF
		if test ! -f ../process/pp_flat_stacked.$ext
			then
			echo -e "\nFailed to create file pp_flat_stacked.$ext; exiting\n"
			exit 1
			fi
		mv ../process/pp_flat_stacked.$ext ../..
		rm -Rf ../process
		cd "$ROOT" >/dev/null
	else
		echo "Found master flat file pp_flat_stacked.$ext"
	fi
fi

# Looking for an optional bad pixels file
if test $(/usr/bin/ls -1 ../../bad_pixels_*.lst 2>/dev/null |head -n1)
	then 
		BAD_PIXELS=$(basename $(/usr/bin/ls -1 ../../bad_pixels_*.lst |head -n1))
		# The argument to be used in calibrate command:
		BPM_ARGUMENT=" -cc=bpm ../../../$BAD_PIXELS "
		echo -e "Will use the bad pixels file $BAD_PIXELS"
	fi	

echo
rm -Rf process