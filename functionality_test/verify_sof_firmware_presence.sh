#!/bin/sh

BIOS_VER=`dmidecode -t bios |grep Version |awk -F : '{print $2}' |cut -b 2-4`
if [ $BIOS_VER == "MNW" ]; then
	PLATFORM="byt"
elif [ $BIOS_VER == "APL" ] || [ $BIOS_VER == "UPA" ]; then
	PLATFORM="apl"
elif [ $BIOS_VER == "CNL" ]; then
	PLATFORM="cnl"
fi

# Verify DSP firmware is presence
ls /lib/firmware/intel/sof-$PLATFORM.ri > /dev/null
if [ $? != 0 ]; then
	echo "Fail: DSP firmware doesnot presence."
	exit 1
else 
        exit 0
fi
