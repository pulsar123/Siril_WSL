#!/bin/bash

# This script is only to be called from inside other scripts
# Its purpose is to find all the required master bias and flat files
# It initializes the values for $BIAS_FLAT and $BIAS, and builds 
# pp_flat_stacked.$ext file if it's missing

# For cr2 files only, getting the ISO value for flats and lights:
name=$(/usr/bin/ls -1 ../FlatWizard/FLAT/20*|head -n1)
file_ext=$(echo $name|rev|cut -d. -f1|rev)
if test $file_ext = "cr2" -o $file_ext = "CR2"
	then
	ISO_FLAT=$(exiftool $name|grep "Base ISO"|cut -d: -f2|cut -d" " -f2)
	BIAS_FLAT=master_bias_ISO${ISO_FLAT}.$ext
	if test ! -f ../../$BIAS_FLAT
		then
			echo -e "\nMissing the bias file: $BIAS_FLAT; exiting\n"
			exit 1
		fi
	name=$(/usr/bin/ls -1 LIGHT/20*|head -n1)
	ISO_LIGHT=$(exiftool $name|grep "Base ISO"|cut -d: -f2|cut -d" " -f2)
	BIAS=master_bias_ISO${ISO_FLAT}.$ext
	if test ! -f ../../$BIAS
		then
		echo -e "\nMissing the bias file: $BIAS; exiting\n"
		exit 1
		fi
	else
		if test $(/usr/bin/ls -1 ../../master_bias_*.$ext |head -n1)
			then 
				BIAS_FLAT=$(basename $(/usr/bin/ls -1 ../../master_bias_*.$ext |head -n1))
				BIAS=$BIAS_FLAT
			else 
				echo "No bias file in the root camera directory; exiting"
				exit 1
			fi	
	fi

echo -e "\nFound bias for flats: $BIAS_FLAT"
echo -e "Found bias for lights: $BIAS"
	
	
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
calibrate flat_ -bias=../../../$BIAS_FLAT
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

# Looking for an optional bad pixels file
if test $(/usr/bin/ls -1 ../../bad_pixels_*.lst |head -n1)
	then 
		BAD_PIXELS=$(basename $(/usr/bin/ls -1 ../../bad_pixels_*.lst |head -n1))
		# The argument to be used in calibrate command:
		BPM_ARGUMENT=" -cc=bpm ../../../$BAD_PIXELS "
		echo -e "\nWill use the bad pixels file $BAD_PIXELS\n"
	fi	
